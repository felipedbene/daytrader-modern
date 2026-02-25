<!DOCTYPE html>
<%@ page
    import="com.ibm.websphere.samples.daytrader.util.TradeConfig"
    session="false" isThreadSafe="true" isErrorPage="false"%>

<jsp:useBean
    class="com.ibm.websphere.samples.daytrader.beans.RunStatsDataBean"
    id="runStatsData" scope="request" />
<%
    double loginPercentage = (double) ((TradeConfig.getScenarioMixes())[0][TradeConfig.LOGOUT_OP]) / 100.0;
    double logoutPercentage = (double) ((TradeConfig.getScenarioMixes())[0][TradeConfig.LOGOUT_OP]) / 100.0;
    double buyOrderPercentage = (double) ((TradeConfig.getScenarioMixes())[0][TradeConfig.BUY_OP]) / 100.0;
    double sellOrderPercentage = (double) ((TradeConfig.getScenarioMixes())[0][TradeConfig.SELL_OP]) / 100.0;
    double orderPercentage = buyOrderPercentage + sellOrderPercentage;
    double registerPercentage = (double) ((TradeConfig.getScenarioMixes())[0][TradeConfig.REGISTER_OP]) / 100.0;

    int logins = runStatsData.getSumLoginCount() - runStatsData.getTradeUserCount();
    if (logins < 0)
        logins = 0;
    double expectedRequests = (double) TradeConfig.getScenarioCount();
    TradeConfig.setScenarioCount(0);

    int verifyPercent = TradeConfig.verifyPercent;
%>
<%!
String verify(double expected, double actual, int verifyPercent) {
    String retVal = "";
    if ((expected == 0.0) || (actual == 0.0))
        return "N/A";
    double check = (actual / expected) * 100 - 100;
    retVal += check + "% ";
    if ((check >= (-1.0 * verifyPercent)) && (check <= verifyPercent))
        retVal += " Pass";
    else
        retVal += " Fail<SUP>4</SUP>";
    if (check > 0.0)
        retVal = "+" + retVal;
    return retVal;
}

String verify(int expected, int actual, int verifyPercent) {
    return verify((double) expected, (double) actual, verifyPercent);
}
%>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DayTrader - Runtime Statistics</title>
    <link rel="stylesheet" href="style.css" type="text/css">
    <link rel="shortcut icon" href="./favicon.ico">
</head>
<body>
    <nav class="dt-nav">
        <a href="index.html" class="dt-brand">
            <span class="dt-brand-icon">DT</span>
            DayTrader
        </a>
        <ul class="dt-nav-links">
            <li><a href="config" target="_self">Modify runtime configuration</a></li>
        </ul>
    </nav>

    <main class="dt-main">
        <%
            String status;
            status = (String) request.getAttribute("status");
            if (status != null) {
        %>
        <div class="dt-alert dt-alert-info"><%=status%></div>
        <%
            }
        %>

        <div class="dt-card">
            <div class="dt-card-header">
                <h2>Benchmark Scenario Statistics</h2>
            </div>
            <div class="dt-card-body">

                <h3 class="dt-section-title">Runtime Configuration Summary</h3>
                <table class="table">
                    <thead>
                        <tr class="tableHeader">
                            <td>Benchmark runtime configuration summary</td>
                            <td>Value</td>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td><a href="docs/glossary.html">Run-Time Mode</a></td>
                            <td><strong><%=(TradeConfig.getRunTimeModeNames())[TradeConfig.runTimeMode]%></strong></td>
                        </tr>
                        <tr>
                            <td><a href="docs/glossary.html">Order-Processing Mode</a></td>
                            <td><strong><%=(TradeConfig.getOrderProcessingModeNames())[TradeConfig.orderProcessingMode]%></strong></td>
                        </tr>
                        <tr>
                            <td><a href="docs/glossary.html">Web Interface</a></td>
                            <td><strong><%=(TradeConfig.getWebInterfaceNames())[TradeConfig.webInterface]%></strong></td>
                        </tr>
                        <tr>
                            <td><a href="docs/glossary.html">Active Traders / Trade User population</a></td>
                            <td><strong><%=runStatsData.getTradeUserCount()%> / <%=TradeConfig.getMAX_USERS()%></strong></td>
                        </tr>
                        <tr>
                            <td><a href="docs/glossary.html">Active Stocks / Trade Stock population</a></td>
                            <td><strong><%=TradeConfig.getMAX_QUOTES()%> / <%=runStatsData.getTradeStockCount()%></strong></td>
                        </tr>
                    </tbody>
                </table>

                <h3 class="dt-section-title" style="margin-top:2rem;">Scenario Verification</h3>
                <div style="overflow-x:auto;">
                <table class="table">
                    <thead>
                        <tr class="tableHeader">
                            <td>Run Statistic</td>
                            <td>Scenario verification test</td>
                            <td>Expected Value</td>
                            <td>Actual Value</td>
                            <td>Pass/Fail</td>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Active Stocks</td>
                            <td>Active stocks should generally equal the db population of stocks</td>
                            <td><%=runStatsData.getTradeStockCount()%></td>
                            <td><strong><%=TradeConfig.getMAX_QUOTES()%></strong></td>
                            <td><%=(runStatsData.getTradeStockCount() == TradeConfig.getMAX_QUOTES()) ? "Pass" : "Warn"%></td>
                        </tr>
                        <tr>
                            <td><a href="docs/glossary.html">Active Traders</a></td>
                            <td>Active traders should generally equal the db population of traders</td>
                            <td><%=runStatsData.getTradeUserCount()%></td>
                            <td><strong><%=TradeConfig.getMAX_USERS()%></strong></td>
                            <td><%=(runStatsData.getTradeUserCount() == TradeConfig.getMAX_USERS()) ? "Pass" : "Warn"%></td>
                        </tr>
                        <tr>
                            <td><a href="docs/glossary.html">Estimated total requests</a></td>
                            <td>Actual benchmark scenario requests should be within +/- 2% of the estimated number of requests in the last benchmark run to pass.</td>
                            <td><%=expectedRequests%></td>
                            <td><strong>see</strong><strong><sup>2</sup></strong></td>
                            <td>see<sup>2</sup></td>
                        </tr>
                        <tr>
                            <td><a href="docs/glossary.html">New Users Registered</a></td>
                            <td><%=registerPercentage * 100%>% of expected requests (<%=registerPercentage%> * <%=expectedRequests%>)</td>
                            <td><%=registerPercentage * expectedRequests%></td>
                            <td><strong><%=runStatsData.getNewUserCount()%></strong></td>
                            <td><%=verify(registerPercentage * expectedRequests, (double) runStatsData.getNewUserCount(), verifyPercent)%></td>
                        </tr>
                        <tr>
                            <td><a href="docs/glossary.html">Logins</a></td>
                            <td><%=loginPercentage * 100%>% of expected requests (<%=loginPercentage%> * <%=expectedRequests%>) + initial login</td>
                            <td><%=loginPercentage * expectedRequests + runStatsData.getTradeUserCount()%></td>
                            <td><strong><%=runStatsData.getSumLoginCount() + runStatsData.getTradeUserCount()%></strong></td>
                            <td><%=verify((double) loginPercentage * expectedRequests, (double) runStatsData.getSumLoginCount(), verifyPercent)%></td>
                        </tr>
                        <tr>
                            <td><a href="docs/glossary.html">Logouts</a></td>
                            <td>#logouts must be &gt;= #logins-active traders ( <%=runStatsData.getSumLoginCount()%> - <%=TradeConfig.getMAX_USERS()%> )</td>
                            <td><%=runStatsData.getSumLoginCount() - TradeConfig.getMAX_USERS()%></td>
                            <td><strong><%=runStatsData.getSumLogoutCount()%></strong></td>
                            <td><%=(runStatsData.getSumLogoutCount() >= (runStatsData.getSumLoginCount() - TradeConfig.getMAX_USERS())) ? "Pass" : "Fail<SUP>4</SUP>"%></td>
                        </tr>
                        <tr>
                            <td><a href="docs/glossary.html">User Holdings</a></td>
                            <td>Trade users own an average of 5 holdings, 5* total Users = ( 5 * <%=runStatsData.getTradeUserCount()%>)</td>
                            <td><%=5 * runStatsData.getTradeUserCount()%></td>
                            <td><strong><%=runStatsData.getHoldingCount()%></strong></td>
                            <td><%=verify(5 * runStatsData.getTradeUserCount(), runStatsData.getHoldingCount(), verifyPercent)%></td>
                        </tr>
                        <tr>
                            <td><a href="docs/glossary.html">Buy Order Count</a></td>
                            <td><%=buyOrderPercentage * 100%>% of expected requests (<%=buyOrderPercentage%> * <%=expectedRequests%>) + current holdings count</td>
                            <td><%=buyOrderPercentage * expectedRequests + runStatsData.getHoldingCount()%></td>
                            <td><strong><%=runStatsData.getBuyOrderCount()%></strong></td>
                            <td><%=verify(buyOrderPercentage * expectedRequests + runStatsData.getHoldingCount(), (double) runStatsData.getBuyOrderCount(), verifyPercent)%></td>
                        </tr>
                        <tr>
                            <td><a href="docs/glossary.html">Sell Order Count</a></td>
                            <td><%=sellOrderPercentage * 100%>% of expected requests (<%=sellOrderPercentage%> * <%=expectedRequests%>)</td>
                            <td><%=sellOrderPercentage * expectedRequests%></td>
                            <td><strong><%=runStatsData.getSellOrderCount()%></strong></td>
                            <td><%=verify(sellOrderPercentage * expectedRequests, (double) runStatsData.getSellOrderCount(), verifyPercent)%></td>
                        </tr>
                        <tr>
                            <td><a href="docs/glossary.html">Total Order Count</a></td>
                            <td><%=orderPercentage * 100%>% of expected requests (<%=orderPercentage%> * <%=expectedRequests%>) + current holdings count</td>
                            <td><%=orderPercentage * expectedRequests + runStatsData.getHoldingCount()%></td>
                            <td><strong><%=runStatsData.getOrderCount()%></strong></td>
                            <td><%=verify(orderPercentage * expectedRequests + runStatsData.getHoldingCount(), (double) runStatsData.getOrderCount(), verifyPercent)%></td>
                        </tr>
                        <tr>
                            <td><a href="docs/glossary.html">Open Orders</a></td>
                            <td>All orders should be completed before reset<sup>3</sup></td>
                            <td>0</td>
                            <td><strong><%=runStatsData.getOpenOrderCount()%></strong></td>
                            <td><%=(runStatsData.getOpenOrderCount() > 0) ? "Fail<SUP>4</SUP>" : "Pass"%></td>
                        </tr>
                        <tr>
                            <td><a href="docs/glossary.html">Cancelled Orders</a></td>
                            <td>Orders are cancelled if an error is encountered during order processing.</td>
                            <td>0</td>
                            <td><strong><%=runStatsData.getCancelledOrderCount()%></strong></td>
                            <td><%=(runStatsData.getCancelledOrderCount() > 0) ? "Fail<SUP>4</SUP>" : "Pass"%></td>
                        </tr>
                        <tr>
                            <td><a href="docs/glossary.html">Orders remaining after reset</a></td>
                            <td>After Trade reset, each user should carry an average of 5 orders in the database. 5* total Users = (5 * <%=runStatsData.getTradeUserCount()%>)</td>
                            <td><%=5 * runStatsData.getTradeUserCount()%></td>
                            <td><strong><%=runStatsData.getOrderCount() - runStatsData.getDeletedOrderCount()%></strong></td>
                            <td><%=verify(5 * runStatsData.getTradeUserCount(), runStatsData.getOrderCount() - runStatsData.getDeletedOrderCount(), verifyPercent)%></td>
                        </tr>
                    </tbody>
                </table>
                </div>

                <ol class="text-secondary" style="margin-top:1.5rem;font-size:0.8125rem;line-height:1.8;">
                    <li>Benchmark verification tests require a Trade Reset between each benchmark run.</li>
                    <li>The expected value of benchmark requests is computed based on the count from the Web application since the last Trade reset. The actual value of benchmark request requires user verification and may be incorrect for a cluster.</li>
                    <li>Orders are processed asynchronously in Trade. Therefore, processing may continue beyond the end of a benchmark run. Trade Reset should not be invoked until processing is completed.</li>
                    <li>Actual values must be within <strong style="color:var(--accent-red);"><%=TradeConfig.verifyPercent%>%</strong> of corresponding estimated values to pass verification.</li>
                </ol>

            </div>
        </div>

        <form action="config" method="POST">
            <input type="hidden" name="action" value="updateConfig">
        </form>
    </main>

    <footer class="dt-footer">
        DayTrader
    </footer>
</body>
</html>
