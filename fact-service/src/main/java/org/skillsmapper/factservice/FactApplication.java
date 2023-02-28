package org.skillsmapper.factservice;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class FactApplication {

	private static final Logger log = LoggerFactory.getLogger(FactApplication.class);

	public static void main(String[] args) {
		SpringApplication.run(FactApplication.class, args);
	}

}
