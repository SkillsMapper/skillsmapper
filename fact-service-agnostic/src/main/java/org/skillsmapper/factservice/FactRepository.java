package org.skillsmapper.factservice;

import org.springframework.data.repository.CrudRepository;

import java.util.List;

public interface FactRepository extends CrudRepository<Fact, String> {

    List<Fact> findByUserUID(String userUID);
    List<Fact> findByLevel(String level);

}
