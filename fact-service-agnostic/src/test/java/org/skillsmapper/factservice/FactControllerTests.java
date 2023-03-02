package org.skillsmapper.factservice;

import org.junit.jupiter.api.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
class FactControllerTests {

  @Autowired private MockMvc mockMvc;

  @Test
  public void shouldBeUnsuccessful_postWithoutToken() throws Exception {
    mockMvc.perform(post("/facts")).andExpect(status().isUnauthorized());
  }

  @Test
  public void shouldBeUnsuccessful_postWithBadToken() throws Exception {
    try {
      mockMvc
          .perform(post("/facts").header("Authorization", "Bearer iam-a-token"))
          .andExpect(status().isForbidden());
    } catch (Exception e) {
      System.out.println("Caught FirebaseApp error");
    }
  }
}
