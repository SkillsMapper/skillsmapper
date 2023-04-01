package org.skillsmapper.factservice;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import java.io.IOException;
import java.util.List;
import javax.annotation.PreDestroy;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class FactApplication {

  private static final Logger log = LoggerFactory.getLogger(FactApplication.class);

  public static void main(String[] args) throws IOException {
    String projectId = System.getenv("PROJECT_ID");

    // Initialize Firebase Admin SDK
    GoogleCredentials credentials = GoogleCredentials.getApplicationDefault();

    FirebaseOptions options = FirebaseOptions.builder()
        .setProjectId(projectId)
        .setCredentials(credentials)
        .build();

    boolean hasBeenInitialized = false;
    List<FirebaseApp> firebaseApps = FirebaseApp.getApps();
    for (FirebaseApp app : firebaseApps) {
      if (app.getName().equals(FirebaseApp.DEFAULT_APP_NAME)) {
        hasBeenInitialized = true;
      }
    }

    if (!hasBeenInitialized) {
      FirebaseApp.initializeApp(options);
    }

    SpringApplication.run(FactApplication.class, args);
  }

  @PreDestroy
  public void tearDown() {
    log.info("{} : received SIGTERM.", FactApplication.class.getSimpleName());
  }
}
