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

import java.util.ArrayList;

import javax.inject.Inject;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import com.ibm.websphere.samples.daytrader.TradeAction;
import com.ibm.websphere.samples.daytrader.beans.MarketSummaryDataBean;

/**
 * REST resource for market summary operations.
 * Provides current market conditions including TSIA index, volume, top gainers/losers.
 */
@Path("/market")
public class MarketSummaryResource {

    @Inject
    private TradeAction tradeAction;

    /**
     * Get current market summary.
     * 
     * @return JSON representation of market summary including TSIA, volume, top gainers/losers
     */
    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public Response getMarketSummary() {
        try {
            MarketSummaryDataBean marketSummary = tradeAction.getMarketSummary();
            if (marketSummary.getTopGainers() != null) {
                marketSummary.setTopGainers(new ArrayList<>(marketSummary.getTopGainers()));
            }
            if (marketSummary.getTopLosers() != null) {
                marketSummary.setTopLosers(new ArrayList<>(marketSummary.getTopLosers()));
            }
            return Response.ok(marketSummary).build();
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(new ErrorResponse("Failed to retrieve market summary", e.getMessage()))
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
