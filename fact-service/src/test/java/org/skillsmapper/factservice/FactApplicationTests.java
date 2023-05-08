package org.skillsmapper.factservice;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class FactApplicationTests {

  @Test
  void contextLoads() {
  }

  @DataJpaTest
  public class FactRepositoryTests {

    @Autowired
    private TestEntityManager entityManager;

    @Autowired
    private FactRepository facts;

    @org.junit.Test
    @Test
    public void testFindByType() {
      Fact fact = new Fact("Dan", "Learning", "GCP");
      entityManager.persist(fact);

      List<Fact> findByType = facts.findByLevel(fact.getLevel());

      assertThat(findByType).extracting(Fact::getLevel).containsOnly(fact.getSkill());
    }
  }
}
