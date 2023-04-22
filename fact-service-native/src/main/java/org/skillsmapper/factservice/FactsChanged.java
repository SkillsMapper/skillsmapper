package org.skillsmapper.factservice;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Objects;

public class FactsChanged {

  private final String user;
  private final List<Fact> facts;
  private final OffsetDateTime timestamp;

  public FactsChanged(String user, List<Fact> facts, OffsetDateTime timestamp)
  {
    this.user = user;
    this.facts = facts;
    this.timestamp = timestamp;
  }

  public String getUser() {
    return user;
  }

  @Override
  public String toString() {
    return "FactsChanged{" +
        "user='" + user + '\'' +
        ", facts=" + facts +
        ", timestamp=" + timestamp +
        '}';
  }

  public List<Fact> getFacts() {
    return facts;
  }

  public OffsetDateTime getTimestamp() {
    return timestamp;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    FactsChanged that = (FactsChanged) o;
    return Objects.equals(user, that.user) && Objects.equals(facts, that.facts)
        && Objects.equals(timestamp, that.timestamp);
  }

  @Override
  public int hashCode() {
    return Objects.hash(user, facts, timestamp);
  }
}
