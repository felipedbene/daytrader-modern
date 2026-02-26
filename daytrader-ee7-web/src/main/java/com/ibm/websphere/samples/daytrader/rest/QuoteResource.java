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
import com.ibm.websphere.samples.daytrader.entities.QuoteDataBean;

/**
 * REST resource for stock quote operations.
 * Provides access to individual stock quotes and all quotes.
 */
@Path("/quotes")
public class QuoteResource {

    @Inject
    private TradeAction tradeAction;

    /**
     * Get quote for a specific stock symbol.
     * 
     * @param symbol the stock symbol
     * @return JSON representation of the quote
     */
    @GET
    @Path("/{symbol}")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getQuote(@PathParam("symbol") String symbol) {
        try {
            QuoteDataBean quote = tradeAction.getQuote(symbol);
            if (quote == null) {
                return Response.status(Response.Status.NOT_FOUND)
                        .entity(new ErrorResponse("Quote not found", "No quote found for symbol: " + symbol))
                        .build();
            }
            return Response.ok(quote).build();
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(new ErrorResponse("Failed to retrieve quote", e.getMessage()))
                    .build();
        }
    }

    /**
     * Get all quotes.
     * 
     * @return JSON array of all quotes
     */
    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public Response getAllQuotes() {
        try {
            Collection<?> quotes = tradeAction.getAllQuotes();
            return Response.ok(quotes).build();
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(new ErrorResponse("Failed to retrieve quotes", e.getMessage()))
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
