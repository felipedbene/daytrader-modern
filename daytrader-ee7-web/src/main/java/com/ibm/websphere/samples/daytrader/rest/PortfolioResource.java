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

import java.util.Collection;

import javax.inject.Inject;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import com.ibm.websphere.samples.daytrader.TradeAction;
import com.ibm.websphere.samples.daytrader.entities.HoldingDataBean;

/**
 * REST resource for portfolio/holdings operations.
 * Provides access to user's stock holdings.
 */
@Path("/portfolio")
public class PortfolioResource {

    @Inject
    private TradeAction tradeAction;

    /**
     * Get all holdings (portfolio) for a specific user.
     * 
     * @param userId the user ID
     * @return JSON array of holdings
     */
    @GET
    @Path("/{userId}")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getPortfolio(@PathParam("userId") String userId) {
        try {
            Collection<?> holdings = tradeAction.getHoldings(userId);
            if (holdings == null || holdings.isEmpty()) {
                return Response.ok(new Object[0]).build();  // Return empty array instead of 404
            }
            return Response.ok(holdings).build();
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(new ErrorResponse("Failed to retrieve portfolio", e.getMessage()))
                    .build();
        }
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
