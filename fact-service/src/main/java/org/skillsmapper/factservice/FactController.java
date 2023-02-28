package org.skillsmapper.factservice;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.server.ResponseStatusException;

@Controller
public class FactController {

    private final FactRepository repository;

    private static final Logger logger = LoggerFactory.getLogger(FactController.class);
    FactController(FactRepository repository) {
        this.repository = repository;
    }

    @GetMapping("/")
    public String index(Model model) {
        try {
            //model.addAttribute("leaderMessage", leaderMessage);
        } catch (DataAccessException e) {
            String message =
                    "Error while connecting to the Cloud SQL database. "
                            + "Check that your username and password are correct and that the "
                            + "PostgreSQL instance, database, and table exists and are ready for use: "
                            + e.toString();
            logger.error(message);
            throw new ResponseStatusException(
                    HttpStatus.INTERNAL_SERVER_ERROR, "Unable to load page; see logs for more details.", e);
        }
        return "index";
    }

    // Aggregate root
    // tag::get-aggregate-root[]
    @GetMapping("/facts")
    @ResponseBody
    Iterable<Fact> all() {
        return repository.findAll();
    }
    // end::get-aggregate-root[]

    @PostMapping("/facts")
    @ResponseBody
    Fact createFact(@RequestBody FactDTO factDTO) {
        Fact fact = new Fact();
        fact.setLevel(factDTO.getLevel());
        fact.setSkill(factDTO.getSkill());
        return repository.save(fact);
    }

    /*
    @RequestMapping(value = "/facts", method = RequestMethod.POST)
    public String createFactForm(@ModelAttribute FactDTO factDTO) {
        logger.info("first Name : {}", firstName);
        logger.info("Last Name : {}", lastName);
        logger.info("Role: {}", role);
        return ResponseEntity.ok().body(firstName);
    }
     */

    // Single item
    @GetMapping("/facts/{id}")
    @ResponseBody
    Fact one(@PathVariable Long id) {

        return repository.findById(id)
                .orElseThrow(() -> new FactNotFoundException(id));
    }

    @PutMapping("/facts/{id}")
    @ResponseBody
    Fact replaceFact(@RequestBody Fact newFact, @PathVariable Long id) {

        return repository.findById(id)
                .map(fact -> {
                    fact.setLevel(newFact.getLevel());
                    fact.setSkill(newFact.getSkill());
                    return repository.save(fact);
                })
                .orElseGet(() -> {
                    newFact.setId(id);
                    return repository.save(newFact);
                });
    }

    @DeleteMapping("/facts/{id}")
    @ResponseBody
    void deleteFact(@PathVariable Long id) {
        repository.deleteById(id);
    }
}
