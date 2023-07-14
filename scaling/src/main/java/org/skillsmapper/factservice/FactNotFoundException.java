package org.skillsmapper.factservice;

public class FactNotFoundException extends RuntimeException {

    public FactNotFoundException(final String id) {
        super(String.format("Could not find fact %s", id));
    }
}
