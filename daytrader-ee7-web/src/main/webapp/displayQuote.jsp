<!--
 * (C) Copyright IBM Corporation 2015.
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
-->
<%@ page
    import="java.math.BigDecimal,com.ibm.websphere.samples.daytrader.TradeServices,com.ibm.websphere.samples.daytrader.TradeAction,com.ibm.websphere.samples.daytrader.entities.QuoteDataBean,com.ibm.websphere.samples.daytrader.util.Log,com.ibm.websphere.samples.daytrader.util.FinancialUtils"
    session="true" isThreadSafe="true" isErrorPage="false"%>
<%
    String symbol = request.getParameter("symbol");
    TradeServices tAction = null;
    tAction = new TradeAction();
    try {
        QuoteDataBean quoteData = tAction.getQuote(symbol);
%>
<tr class="tableOddRow" style="text-align:center;">
    <td><%=FinancialUtils.printQuoteLink(quoteData.getSymbol())%></td>
    <td><%=quoteData.getCompanyName()%></td>
    <td><%=quoteData.getVolume()%></td>
    <td><%=quoteData.getLow() + " - " + quoteData.getHigh()%></td>
    <td style="white-space:nowrap;"><%=quoteData.getOpen()%></td>
    <td>$ <%=quoteData.getPrice()%></td>
    <td><%=FinancialUtils.printGainHTML(new BigDecimal(quoteData.getChange()))%>
        <%=FinancialUtils.printGainPercentHTML(FinancialUtils.computeGainPercent(quoteData.getPrice(), quoteData.getOpen()))%></td>
    <td>
        <form action="" style="display:flex;gap:0.25rem;align-items:center;justify-content:center;">
            <input type="submit" name="action" value="buy" class="dt-btn dt-btn-sm">
            <input type="hidden" name="symbol" value="<%=quoteData.getSymbol()%>">
            <input size="4" type="text" name="quantity" value="100">
        </form>
    </td>
</tr>

<%
    } catch (Exception e) {
        Log.error("displayQuote.jsp exception. Check that symbol: " + symbol + " exists in the database.", e);
    }
%>
