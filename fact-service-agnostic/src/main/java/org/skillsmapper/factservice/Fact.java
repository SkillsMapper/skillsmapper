package org.skillsmapper.factservice;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;

@Entity
public class Fact {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    private String person;

    private String level;

    private String skill;

    protected Fact() {
    }

    public Fact(String person, String level, String skill) {
        this.person = person;
        this.level = level;
        this.skill = skill;
    }

    public Long getId() {
        return id;
    }

    public String getLevel() {
        return level;
    }

    public String getSkill() {
        return skill;
    }

    public String getPerson() {
        return person;
    }

    @Override
    public String toString() {
        return "Fact{" +
                "id=" + id +
                ", person='" + person + '\'' +
                ", type='" + level + '\'' +
                ", skill='" + skill + '\'' +
                '}';
    }

    public void setPerson(final String person) {
        this.person = person;
    }

    public void setSkill(final String skill) {
        this.skill = skill;
    }

    public void setLevel(final String type) {
        this.level = type;
    }

    public void setId(final Long id) {
        this.id = id;
    }
}
