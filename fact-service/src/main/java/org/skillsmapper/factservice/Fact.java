package org.skillsmapper.factservice;

import java.time.OffsetDateTime;
import java.util.Objects;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "facts")
public class Fact {

  @Id
  @GeneratedValue(strategy = GenerationType.AUTO)
  private Long id;

  private OffsetDateTime timestamp;

  @Column(name = "user_id")
  private String user;

  private String level;

  private String skill;

  protected Fact() {
  }

  public Fact(String user, String level, String skill) {
    this.user = user;
    this.timestamp = OffsetDateTime.now();
    this.level = level;
    this.skill = skill;
  }

  public Long getId() {
    return id;
  }

  public void setId(final Long id) {
    this.id = id;
  }

  public String getLevel() {
    return level;
  }

  public void setLevel(final String type) {
    this.level = type;
  }

  public String getSkill() {
    return skill;
  }

  public void setSkill(final String skill) {
    this.skill = skill;
  }

  public OffsetDateTime getTimestamp() {
    return timestamp;
  }

  public void setTimestamp(final OffsetDateTime timestamp) {
    this.timestamp = timestamp;
  }

  public String getUser() {
    return user;
  }

  public void setUser(final String person) {
    this.user = person;
  }

  @Override
  public String toString() {
    return "Fact{" +
        "id=" + id +
        ", timestamp=" + timestamp +
        ", userUID='" + user + '\'' +
        ", level='" + level + '\'' +
        ", skill='" + skill + '\'' +
        '}';
  }

  @Override
  public boolean equals(final Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    final Fact fact = (Fact) o;
    return Objects.equals(id, fact.id) && Objects.equals(timestamp, fact.timestamp)
        && Objects.equals(user, fact.user) && Objects.equals(level,
        fact.level) && Objects.equals(skill, fact.skill);
  }

  @Override
  public int hashCode() {
    return Objects.hash(id, timestamp, user, level, skill);
  }

}
