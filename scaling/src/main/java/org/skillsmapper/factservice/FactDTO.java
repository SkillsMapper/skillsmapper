package org.skillsmapper.factservice;

public class FactDTO {

    private String level;

    private String skill;

    public FactDTO(final String level, final String skill) {
        this.level = level;
        this.skill = skill;
    }

    public String getSkill() {
        return skill;
    }

    public void setSkill(final String skill) {
        this.skill = skill;
    }

    public String getLevel() {
        return level;
    }

    public void setLevel(final String level) {
        this.level = level;
    }
}
