/**
 * (C) Copyright IBM Corporation 2015, 2025.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.ibm.websphere.samples.daytrader.rest;

import java.security.Principal;

import javax.inject.Inject;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.SecurityContext;

import com.ibm.websphere.samples.daytrader.TradeAction;
import com.ibm.websphere.samples.daytrader.entities.AccountDataBean;
import com.ibm.websphere.samples.daytrader.entities.AccountProfileDataBean;

/**
 * REST resource for account operations.
 * Provides access to account information and login functionality.
 */
@Path("/accounts")
public class AccountResource {

    @Inject
    private TradeAction tradeAction;

    @Context
    private SecurityContext securityContext;

    /**
     * Get account information for a specific user.
     * Requires the authenticated OIDC principal to match the requested userId.
     *
     * @param userId the user ID
     * @return JSON representation of the account including profile
     */
    @GET
    @Path("/{userId}")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getAccount(@PathParam("userId") String userId) {
        Principal principal = securityContext.getUserPrincipal();
        if (principal == null || !principal.getName().equals(userId)) {
            return Response.status(Response.Status.FORBIDDEN)
                    .entity(new ErrorResponse("Access denied", "You can only access your own account"))
                    .build();
        }
        try {
            AccountDataBean account = tradeAction.getAccountData(userId);
            if (account == null) {
                return Response.status(Response.Status.NOT_FOUND)
                        .entity(new ErrorResponse("Account not found", "No account found for user: " + userId))
                        .build();
            }
            return Response.ok(account).build();
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(new ErrorResponse("Failed to retrieve account", e.getMessage()))
                    .build();
        }
    }

    /**
     * Login user and return account data.
     * 
     * @param loginRequest contains userId and password
     * @return JSON representation of account data
     */
    @POST
    @Path("/login")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response login(LoginRequest loginRequest) {
        try {
            if (loginRequest == null || loginRequest.userId == null || loginRequest.password == null) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity(new ErrorResponse("Invalid request", "userId and password are required"))
                        .build();
            }

            AccountDataBean account = tradeAction.login(loginRequest.userId, loginRequest.password);
            if (account == null) {
                return Response.status(Response.Status.UNAUTHORIZED)
                        .entity(new ErrorResponse("Login failed", "Invalid credentials"))
                        .build();
            }
            return Response.ok(account).build();
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(new ErrorResponse("Login failed", e.getMessage()))
                    .build();
        }
    }

    /**
     * Login request POJO for JSON deserialization.
     */
    public static class LoginRequest {
        public String userId;
        public String password;
    }

    /**
     * Simple error response POJO for JSON serialization.
     */
    public static class ErrorResponse {
        public String error;
        public String message;

        public ErrorResponse(String error, String message) {
            this.error = error;
            this.message = message;
        }
    }
}
