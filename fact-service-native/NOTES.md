# Notes

## TODO:

* --HATEOS: https://www.baeldung.com/spring-hateoas-tutorial--
* --Swagger--
    * https://www.baeldung.com/swagger-2-documentation-for-spring-rest-api
    * https://github.com/spring-guides/tut-rest/blob/main/rest/src/main/java/payroll/EmployeeController.java

## To add to chapter

* OpenAPI instructions
* Reiterate important concepts e.g. sigterm

## Database connection options

Private IP:

* via socket (internal)
* via Cloud SQL Proxy

Public IP:

* Connect via socket (internal only if not in authorised network)
* Connect via IP (if on authorised network)
* Connect via socket from authorised external network
* Connect via Cloud SQL Proxy (Cloud Run provides a proxy)

Requires Google Libraries:

https://spring-gcp.saturnism.me/

=== Start with Cloud Run

* Fast startup e.g. Go 1s
* Cloud Run with a Dockerfile
* Cloud SQL with a proxy
* Can Cloud run do multi-region

Disadvantages:

* Notice how slow it is to upload and deploy compared to Go.

=== When to switch to GKE Autopilot

* Slow startup e.g. Java - 20s
* When running 24/7 or millions of requests
* Multi-region
* GKE Autopilot
* Cloud SQL without a proxy
* Need to use sidecars

Disadvantages:

* More complex to expose (service + Ingress)

=== Cost

* Autopilot clusters accrue a flat fee of $0.10/hour for each cluster after the free tier

=== When to Switch to GKE Classic

* GKE slow to deploy as pods pending while cluster spins up - minutes to stabilise

ChatGPT Test:

package org.skillsmapper.factservice;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.BDDMockito.given;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import java.util.Collections;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.test.web.servlet.MockMvc;

@ExtendWith(SpringExtension.class)
@WebMvcTest(FactController.class)
public class FactControllerTests {

@Autowired
private MockMvc mockMvc;

@MockBean
private FactRepository factRepository;

// @MockBean
//private FirebaseAuth firebaseAuth;

private FirebaseToken mockFirebaseToken;

private Fact fact1;

@BeforeEach
public void setUp() throws FirebaseAuthException {
fact1 = new Fact("user1", "leaning", "Java");
/*
// Mock the FirebaseToken
mockFirebaseToken = mock(FirebaseToken.class);
when(mockFirebaseToken.getUid()).thenReturn("user1");

    // Mock the FirebaseAuth
    when(firebaseAuth.verifyIdToken(anyString())).thenReturn(mockFirebaseToken);
*/
given(factRepository.findByUserUID(anyString())).willReturn(Collections.singletonList(fact1));
given(factRepository.findById(1L)).willReturn(Optional.of(fact1));
given(factRepository.findById(2L)).willReturn(Optional.empty());
given(factRepository.save(any(Fact.class))).willReturn(fact1);
}

@Test
public void getAllFacts() throws Exception {
//given(firebaseAuth.verifyIdToken(anyString())).willReturn(mockFirebaseToken);

    mockMvc.perform(get("/facts")
            .header("Authorization", "Bearer fake-token"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$._embedded.factList[0].id").value(fact1.getId()))
        .andExpect(jsonPath("$._embedded.factList[0].skill").value(fact1.getSkill()));
}

@Test
public void getOneFact() throws Exception {
//given(firebaseAuth.verifyIdToken(anyString())).willReturn(mockFirebaseToken);

    mockMvc.perform(get("/facts/1")
            .header("Authorization", "Bearer fake-token"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.id").value(fact1.getId()))
        .andExpect(jsonPath("$.skill").value(fact1.getSkill()));
}

@Test
public void createFact() throws Exception {
//given(firebaseAuth.verifyIdToken(anyString())).willReturn(mockFirebaseToken);

    String factCreateRequestJson = "{\"skill\": \"Java\", \"level\": 3}";

    mockMvc.perform(post("/facts")
            .header("Authorization", "Bearer fake-token")
            .contentType(MediaType.APPLICATION_JSON)
            .content(factCreateRequestJson))
        .andExpect(status().isCreated())
        .andExpect(jsonPath("$.id").value(fact1.getId()))
        .andExpect(jsonPath("$.skill").value(fact1.getSkill()));
}

@Test
public void deleteFact() throws Exception {
// given(firebaseAuth.verifyIdToken(anyString())).willReturn(mockFirebaseToken);

    mockMvc.perform(delete("/facts/1")
        .header("Authorization", "Bearer fake-token"));
    mockMvc.perform(delete("/facts/1")
            .header("Authorization", "Bearer fake-token"))
        .andExpect(status().isNoContent());
}

@Test
public void deleteFact_NotFound() throws Exception {
//given(firebaseAuth.verifyIdToken(anyString())).willReturn(mockFirebaseToken);

    mockMvc.perform(delete("/facts/2")
            .header("Authorization", "Bearer fake-token"))
        .andExpect(status().isNotFound());
}

@Test
public void deleteFact_Forbidden() throws Exception {
// given(firebaseAuth.verifyIdToken(anyString())).willReturn(mockFirebaseToken);

    mockMvc.perform(delete("/facts/1")
            .header("Authorization", "Bearer fake-token"))
        .andExpect(status().isForbidden());
}
}
