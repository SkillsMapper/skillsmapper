package org.skillsmapper.factservice;

public class FactNotFoundException extends RuntimeException {

    public FactNotFoundException(final Long id) {
        super(String.format("Could not find fact %s", id));
    }
}
