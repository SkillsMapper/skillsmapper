package org.skillsmapper.factservice;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import org.skillsmapper.factservice.FactApplication.PubsubOutboundGateway;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.hateoas.CollectionModel;
import org.springframework.hateoas.EntityModel;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.linkTo;
import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.methodOn;

@RestController
@RequestMapping(value = "/facts", produces = "application/hal+json")
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class FactController {

  private static final Logger logger = LoggerFactory.getLogger(FactController.class);
  private final FactRepository factRepository;
  private final PubsubOutboundGateway messagingGateway;

  public void factsChanged(Fact fact) {
    List<Fact> facts = factRepository.findByUser(fact.getUser());
    FactsChanged factsChanged = new FactsChanged(fact.getUser(), facts, OffsetDateTime.now());
    ObjectMapper objectMapper = new ObjectMapper();
    objectMapper.registerModule(new JavaTimeModule());
    objectMapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
    objectMapper.disable(SerializationFeature.WRITE_DATES_WITH_CONTEXT_TIME_ZONE);
    try {
      String jsonString = objectMapper.writeValueAsString(factsChanged);
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
  @GetMapping
  @ResponseBody
  CollectionModel<EntityModel<Fact>> all(@RequestHeader Map<String, String> headers) {
    List<EntityModel<Fact>> facts = factRepository.findByUser(authenticateJwt(headers)).stream()
        .map(fact -> EntityModel.of(fact,
            linkTo(methodOn(FactController.class).one(fact.getId(), headers)).withSelfRel(),
            linkTo(methodOn(FactController.class).delete(fact.getId(), headers)).withRel("delete"),
            linkTo(methodOn(FactController.class).all(headers)).withRel("facts")))
        .collect(Collectors.toList());
    return CollectionModel.of(facts,
        linkTo(methodOn(FactController.class).all(headers)).withSelfRel());
  }

  @PostMapping
  @ResponseBody
  @ResponseStatus(HttpStatus.CREATED)
  Fact createFact(@RequestHeader Map<String, String> headers,
      @RequestBody FactCreateRequest factCreateRequest) {
    Fact fact = new Fact();
    fact.setUser(authenticateJwt(headers));
    fact.setTimestamp(OffsetDateTime.now());
    fact.setLevel(factCreateRequest.getLevel());
    fact.setSkill(factCreateRequest.getSkill());
    logger.debug("Saving fact: {}", fact);
    factRepository.save(fact);
    factsChanged(fact);
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
              if (fact.getUser().equals(authenticateJwt(headers))) {
                logger.debug("Deleting fact: {}", id);
                factRepository.deleteById(id);
                factsChanged(fact);
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
    String idToken = null;

    String forwardedAuthHeader = headers.get("x-forwarded-authorization");
    if (forwardedAuthHeader != null) {
      idToken = getTokenFromHeader(forwardedAuthHeader);
      logger.info("using 'x-forwarded-authorization' header for authentication");
    }

    if (idToken == null) {
      String authHeader = headers.get("authorization");
      if (authHeader == null) {
        authHeader = headers.get("Authorization");
      }
      if (authHeader != null) {
        idToken = getTokenFromHeader(authHeader);
        logger.info("using 'authorization' header for authentication");
      } else {
        logger.error("Error: no authorization header");
        throw new ResponseStatusException(HttpStatus.UNAUTHORIZED);
      }
    }

    // If the provided ID token has the correct format, is not expired, and is
    // properly signed, the method returns the decoded ID token
    try {
      FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
      return decodedToken.getUid();
    } catch (FirebaseAuthException e) {
      logger.error("Error when authenticating: {}", e.getMessage());
      throw new ResponseStatusException(HttpStatus.FORBIDDEN);
    }
  }

  private String getTokenFromHeader(String header) {
    String[] parts = header.split(" ");
    if (parts.length == 2) {
      return parts[1];
    }
    return null;
  }
}
