package org.skillsmapper.factservice;

import java.util.List;

import org.springframework.data.repository.CrudRepository;

public interface FactRepository extends CrudRepository<Fact, Long> {

    List<Fact> findByUserUID(String userUID);
    List<Fact> findByLevel(String level);
    Fact findById(long id);
}
