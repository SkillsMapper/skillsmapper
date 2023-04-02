package org.skillsmapper.factservice;

import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.linkTo;
import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.methodOn;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import org.skillsmapper.factservice.FactApplication.PubsubOutboundGateway;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.hateoas.CollectionModel;
import org.springframework.hateoas.EntityModel;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping(value = "/facts", produces = "application/hal+json")
public class FactController {

  private static final Logger logger = LoggerFactory.getLogger(FactController.class);
  private final FactRepository factRepository;
  private final PubsubOutboundGateway messagingGateway;

  public void factChanged(Fact fact) {
    List<Fact> facts = factRepository.findByUserUID(fact.getUserUID());
    ObjectMapper objectMapper = new ObjectMapper();
    objectMapper.registerModule(new JavaTimeModule());
    try {
      String jsonString = objectMapper.writeValueAsString(facts);
      logger.info("Sending message to Pub/Sub: {}", jsonString);
      messagingGateway.sendToPubsub(jsonString);
    } catch (JsonProcessingException e) {
      logger.error("Error serialising message send to Pub/Sub: {}", e.getMessage());
    }
  }

  FactController(FactRepository factRepository, PubsubOutboundGateway messagingGateway) {
    this.factRepository = factRepository;
    this.messagingGateway = messagingGateway;
  }

  // Aggregate root
  // tag::get-aggregate-root[]
  @GetMapping
  @ResponseBody
  CollectionModel<EntityModel<Fact>> all(@RequestHeader Map<String, String> headers) {
    List<EntityModel<Fact>> facts = factRepository.findByUserUID(authenticateJwt(headers)).stream()
        .map(fact -> EntityModel.of(fact,
            linkTo(methodOn(FactController.class).one(fact.getId(), headers)).withSelfRel(),
            linkTo(methodOn(FactController.class).delete(fact.getId(), headers)).withRel("delete"),
            linkTo(methodOn(FactController.class).all(headers)).withRel("facts")))
        .collect(Collectors.toList());
    return CollectionModel.of(facts,
        linkTo(methodOn(FactController.class).all(headers)).withSelfRel());
  }
  // end::get-aggregate-root[]

  @PostMapping
  @ResponseBody
  @ResponseStatus(HttpStatus.CREATED)
  Fact createFact(@RequestHeader Map<String, String> headers,
      @RequestBody FactCreateRequest factCreateRequest) {
    Fact fact = new Fact();
    fact.setUserUID(authenticateJwt(headers));
    fact.setTimestamp(LocalDateTime.now());
    fact.setLevel(factCreateRequest.getLevel());
    fact.setSkill(factCreateRequest.getSkill());
    logger.debug("Saving fact: {}", fact);
    factRepository.save(fact);
    factChanged(fact);
    return fact;
  }

  // Single item
  @GetMapping("/{id}")
  @ResponseBody
  EntityModel<Fact> one(@PathVariable Long id, @RequestHeader Map<String, String> headers) {
    Fact fact = factRepository.findById(id)
        .orElseThrow(() -> new FactNotFoundException(id));
    return EntityModel.of(fact,
        linkTo(methodOn(FactController.class).one(id, headers)).withSelfRel(),
        linkTo(methodOn(FactController.class).all(headers)).withRel("facts"));
  }

  @DeleteMapping("/{id}")
  @ResponseBody
  @ResponseStatus(HttpStatus.NO_CONTENT)
  ResponseEntity<Object> delete(@PathVariable Long id, @RequestHeader Map<String, String> headers) {
    return factRepository
        .findById(id)
        .map(
            fact -> {
              // Only allow deletion of facts created by the authenticated user
              if (fact.getUserUID().equals(authenticateJwt(headers))) {
                logger.debug("Deleting fact: {}", id);
                factRepository.deleteById(id);
                factChanged(fact);
              } else {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                    "You are not allowed to delete this fact");
              }
              return ResponseEntity.noContent().build();
            })
        .orElseThrow(() -> new FactNotFoundException(id));
  }

  /**
   * Extract and verify ID Token from header
   */
  private String authenticateJwt(Map<String, String> headers) {
    String authHeader =
        (headers.get("authorization") != null)
            ? headers.get("authorization")
            : headers.get("Authorization");
    if (authHeader != null) {
      String idToken = authHeader.split(" ")[1];
      // If the provided ID token has the correct format, is not expired, and is
      // properly signed, the method returns the decoded ID token
      try {
        FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
        return decodedToken.getUid();
      } catch (FirebaseAuthException e) {
        logger.error("Error when authenticating: {}", e.getMessage());
        throw new ResponseStatusException(HttpStatus.FORBIDDEN);
      }
    } else {
      logger.error("Error: no authorization header");
      throw new ResponseStatusException(HttpStatus.UNAUTHORIZED);
    }
  }

}
