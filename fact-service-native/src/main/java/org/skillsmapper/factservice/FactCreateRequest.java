package org.skillsmapper.factservice;

public class FactCreateRequest {

  private final String level;

  private final String skill;

  public FactCreateRequest(final String level, final String skill) {
    this.level = level;
    this.skill = skill;
  }

  public String getSkill() {
    return skill;
  }

  public String getLevel() {
    return level;
  }

}
