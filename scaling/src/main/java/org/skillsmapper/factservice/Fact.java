package org.skillsmapper.factservice;

import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Objects;
import java.util.UUID;

@Entity
@Table(name = "Facts")
public class Fact {

    @Id
    private String id;

    private String timestamp;

    private String timezone;

    private String userUID;

    private String level;

    private String skill;

    protected Fact() {
    }

    public Fact(String userUID, String level, String skill) {
        this.id = UUID.randomUUID().toString();
        this.userUID = userUID;
        ZonedDateTime zonedDateTime = ZonedDateTime.now();
        this.timestamp = DateTimeFormatter.ISO_INSTANT.format(zonedDateTime);
        this.timezone = zonedDateTime.getZone().toString();
        this.level = level;
        this.skill = skill;
    }

    public String getId() {
        return id;
    }

    public String getLevel() {
        return level;
    }

    public String getSkill() {
        return skill;
    }

    public String getUserUID() {
        return userUID;
    }

    public ZonedDateTime getTimestamp() {
        return ZonedDateTime.parse(this.timestamp + "[" + this.timezone + "]", DateTimeFormatter.ISO_ZONED_DATE_TIME);
    }

    public void setTimestamp(final ZonedDateTime timestamp) {
        this.timestamp = DateTimeFormatter.ISO_INSTANT.format(timestamp);
        this.timezone = timestamp.getZone().toString();
    }

    @Override
    public String toString() {
        return "Fact{" +
                "id=" + id +
                ", timestamp=" + timestamp +
                ", userUID='" + userUID + '\'' +
                ", level='" + level + '\'' +
                ", skill='" + skill + '\'' +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Fact fact = (Fact) o;
        return Objects.equals(id, fact.id) && Objects.equals(timestamp, fact.timestamp) && Objects.equals(userUID, fact.userUID) && Objects.equals(level, fact.level) && Objects.equals(skill, fact.skill);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, timestamp, userUID, level, skill);
    }

    public void setUserUID(final String person) {
        this.userUID = person;
    }

    public void setSkill(final String skill) {
        this.skill = skill;
    }

    public void setLevel(final String type) {
        this.level = type;
    }

    public void setId(final String id) {
        this.id = id;
    }
}
