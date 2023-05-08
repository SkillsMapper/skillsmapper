package org.skillsmapper.factservice;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.NOT_FOUND)
public class FactNotFoundException extends RuntimeException {

  public FactNotFoundException(final Long id) {
    super(String.format("Could not find fact %s", id));
  }
}
