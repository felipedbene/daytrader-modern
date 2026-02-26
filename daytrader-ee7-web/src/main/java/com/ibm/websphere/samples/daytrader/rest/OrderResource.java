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
import java.util.ArrayList;
import java.util.Collection;

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
import com.ibm.websphere.samples.daytrader.entities.OrderDataBean;
import com.ibm.websphere.samples.daytrader.util.TradeConfig;

/**
 * REST resource for order operations.
 * Provides access to orders and functionality to place buy/sell orders.
 */
@Path("/orders")
public class OrderResource {

    @Inject
    private TradeAction tradeAction;

    @Context
    private SecurityContext securityContext;

    /**
     * Get all orders for a specific user.
     * Requires the authenticated OIDC principal to match the requested userId.
     *
     * @param userId the user ID
     * @return JSON array of orders
     */
    @GET
    @Path("/{userId}")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getOrders(@PathParam("userId") String userId) {
        Principal principal = securityContext.getUserPrincipal();
        if (principal == null || !principal.getName().equals(userId)) {
            return Response.status(Response.Status.FORBIDDEN)
                    .entity(new ErrorResponse("Access denied", "You can only access your own orders"))
                    .build();
        }
        try {
            Collection<?> orders = tradeAction.getOrders(userId);
            if (orders == null || orders.isEmpty()) {
                return Response.ok(new ArrayList<>()).build();
            }
            return Response.ok(new ArrayList<>(orders)).build();
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(new ErrorResponse("Failed to retrieve orders", e.getMessage()))
                    .build();
        }
    }

    /**
     * Place a buy or sell order.
     * 
     * @param orderRequest contains order details (buy/sell, userId, symbol, quantity, holdingId)
     * @return JSON representation of the created order
     */
    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response placeOrder(OrderRequest orderRequest) {
        try {
            if (orderRequest == null || orderRequest.userId == null) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity(new ErrorResponse("Invalid request", "userId is required"))
                        .build();
            }

            Principal principal = securityContext.getUserPrincipal();
            if (principal == null || !principal.getName().equals(orderRequest.userId)) {
                return Response.status(Response.Status.FORBIDDEN)
                        .entity(new ErrorResponse("Access denied", "You can only place orders for your own account"))
                        .build();
            }

            OrderDataBean order;
            
            if ("buy".equalsIgnoreCase(orderRequest.orderType)) {
                // Buy order requires symbol and quantity
                if (orderRequest.symbol == null || orderRequest.quantity <= 0) {
                    return Response.status(Response.Status.BAD_REQUEST)
                            .entity(new ErrorResponse("Invalid request", "symbol and positive quantity are required for buy orders"))
                            .build();
                }
                
                // Use default order processing mode (synchronous)
                int orderProcessingMode = TradeConfig.orderProcessingMode;
                order = tradeAction.buy(orderRequest.userId, orderRequest.symbol, 
                                       orderRequest.quantity, orderProcessingMode);
                
            } else if ("sell".equalsIgnoreCase(orderRequest.orderType)) {
                // Sell order requires holdingId
                if (orderRequest.holdingId == null) {
                    return Response.status(Response.Status.BAD_REQUEST)
                            .entity(new ErrorResponse("Invalid request", "holdingId is required for sell orders"))
                            .build();
                }
                
                // Use default order processing mode (synchronous)
                int orderProcessingMode = TradeConfig.orderProcessingMode;
                order = tradeAction.sell(orderRequest.userId, orderRequest.holdingId, orderProcessingMode);
                
            } else {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity(new ErrorResponse("Invalid request", "orderType must be 'buy' or 'sell'"))
                        .build();
            }

            if (order == null) {
                return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                        .entity(new ErrorResponse("Order failed", "Order could not be placed"))
                        .build();
            }

            return Response.status(Response.Status.CREATED).entity(order).build();
            
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(new ErrorResponse("Failed to place order", e.getMessage()))
                    .build();
        }
    }

    /**
     * Order request POJO for JSON deserialization.
     */
    public static class OrderRequest {
        public String orderType;    // "buy" or "sell"
        public String userId;
        public String symbol;       // Required for buy orders
        public double quantity;     // Required for buy orders
        public Integer holdingId;   // Required for sell orders
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
