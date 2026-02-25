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
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Content-Style-Type" content="text/css">
    <link rel="shortcut icon" href="./favicon.ico">
    <link rel="stylesheet" href="style.css">
    <title>DayTrader Configuration</title>
</head>
<body>
    <%@ page
        import="com.ibm.websphere.samples.daytrader.util.TradeConfig"
        session="false" isThreadSafe="true" isErrorPage="false"%>

    <nav class="dt-nav">
        <a href="index.html" class="dt-brand">
            <span class="dt-brand-icon">DT</span>
            DayTrader
        </a>
    </nav>

    <main class="dt-main">

        <%
            String status;
            status = (String) request.getAttribute("status");
            if (status != null) {
        %>
        <div class="dt-alert dt-alert-info"><%= status %></div>
        <%
            }
        %>

        <h2>Configuration</h2>

        <FORM action="config" method="POST">
            <INPUT type="hidden" name="action" value="updateConfig">

            <div class="dt-card">
                <div class="dt-card-header">
                    <h3>Runtime Settings</h3>
                </div>
                <div class="dt-card-body">
                    <p>The current DayTrader runtime configuration is detailed below. View and
                        optionally update run-time parameters.</p>
                    <p><strong>NOTE:</strong> Parameter settings will return to default on server restart.
                        To make configuration settings persistent across application server stop/starts,
                        edit the daytrader.props file inside daytrader-ee7-web.war (which is inside the
                        daytrader ear file).</p>
                </div>

                <table class="dt-test-table">
                    <thead>
                        <tr>
                            <th style="width: 35%;">Setting</th>
                            <th>Description</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>
                                <strong>Run-Time Mode</strong><br><br>
                                <%
                                    String configParm = "RunTimeMode";
                                    String names[] = TradeConfig.runTimeModeNames;
                                    int index = TradeConfig.runTimeMode;
                                    for (int i = 0; i < names.length; i++) {
                                        out.print("<INPUT type=\"radio\" name=\"" + configParm + "\" value=\"" + i + "\" ");
                                        if (index == i)
                                            out.print("checked");
                                        out.print("> " + names[i] + "<BR>");
                                    }
                                %>
                            </td>
                            <td>Run Time Mode determines server implementation of the TradeServices to use
                                in the DayTrader application Enterprise Java Beans including Session, Entity
                                and Message beans or Direct mode which uses direct database and JMS access.
                                See <a href="docs/tradeFAQ.html">DayTrader FAQ</a> for details.</td>
                        </tr>
                        <tr>
                            <td>
                                <INPUT type="checkbox"
                                    <%=TradeConfig.useRemoteEJBInterface() ? "checked" : ""%>
                                    name="UseRemoteEJBInterface">
                                <strong>Use Remote EJB Interface</strong>
                            </td>
                            <td>EJB3 Mode Only. By default a local interface is used.</td>
                        </tr>
                        <tr>
                            <td>
                                <strong>Order-Processing Mode</strong><br><br>
                                <%
                                    configParm = "OrderProcessingMode";
                                    names = TradeConfig.orderProcessingModeNames;
                                    index = TradeConfig.orderProcessingMode;
                                    for (int i = 0; i < names.length; i++) {
                                        out.print("<INPUT type=\"radio\" name=\"" + configParm + "\" value=\"" + i + "\" ");
                                        if (index == i)
                                            out.print("checked");
                                        out.print("> " + names[i] + "<BR>");
                                    }
                                %>
                            </td>
                            <td>Order Processing Mode determines the mode for completing stock purchase
                                and sell operations. Synchronous mode completes the order immediately.
                                Asynchronous_2-Phase performs a 2-phase commit over the EJB Entity/DB and
                                MDB/JMS transactions. See <a href="docs/tradeFAQ.html">DayTrader FAQ</a> for details.</td>
                        </tr>
                        <tr>
                            <td>
                                <strong>WebInterface</strong><br><br>
                                <%
                                    configParm = "WebInterface";
                                    names = TradeConfig.webInterfaceNames;
                                    index = TradeConfig.webInterface;
                                    for (int i = 0; i < names.length; i++) {
                                        out.print("<INPUT type=\"radio\" name=\"" + configParm + "\" value=\"" + i + "\" ");
                                        if (index == i)
                                            out.print("checked");
                                        out.print("> " + names[i] + "<BR>");
                                    }
                                %>
                            </td>
                            <td>This setting determines the Web interface technology used, JSPs or JSPs
                                with static images and GIFs.</td>
                        </tr>

                        <tr>
                            <td colspan="2" class="section-header">Miscellaneous Settings</td>
                        </tr>

                        <tr>
                            <td>
                                <strong>DayTrader Max Users</strong><br>
                                <INPUT size="25" type="text" name="MaxUsers"
                                    value="<%=TradeConfig.getMAX_USERS()%>"><br><br>
                                <strong>Trade Max Quotes</strong><br>
                                <INPUT size="25" type="text" name="MaxQuotes"
                                    value="<%=TradeConfig.getMAX_QUOTES() %>">
                            </td>
                            <td>By default the DayTrader database is populated with 15,000 users
                                (uid:0 - uid:199) and 10,000 quotes (s:0 - s:399).</td>
                        </tr>
                        <tr>
                            <td>
                                <strong>Market Summary Interval</strong><br>
                                <INPUT size="25" type="text" name="marketSummaryInterval"
                                    value="<%=TradeConfig.getMarketSummaryInterval()%>">
                            </td>
                            <td>&lt; 0 Do not perform Market Summary Operations.<br>
                                = 0 Perform Market Summary on every request.<br>
                                &gt; 0 Number of seconds between Market Summary Operations.</td>
                        </tr>
                        <tr>
                            <td>
                                <strong>Primitive Iteration</strong><br>
                                <INPUT size="25" type="text" name="primIterations"
                                    value="<%=TradeConfig.getPrimIterations()%>">
                            </td>
                            <td>By default the DayTrader primitives execute one operation per web request.
                                Change this value to repeat operations multiple times per web request.</td>
                        </tr>
                        <tr>
                            <td>
                                <INPUT type="checkbox"
                                    <%=TradeConfig.getPublishQuotePriceChange() ? "checked" : ""%>
                                    name="EnablePublishQuotePriceChange">
                                <strong>Publish Quote Updates</strong>
                            </td>
                            <td>Publish quote price changes to a JMS topic.</td>
                        </tr>
                        <tr>
                            <td>
                                <strong>Percent of Trades To Display</strong><br>
                                <INPUT size="25" type="text" name="percentSentToWebsocket"
                                    value="<%=TradeConfig.getPercentSentToWebsocket()%>">
                            </td>
                            <td>The percent of recent trades to display on the Market Summary websocket.
                                This requires the enabling of publish quote price updates above.</td>
                        </tr>
                        <tr>
                            <td>
                                <INPUT type="checkbox"
                                    <%=TradeConfig.getDisplayOrderAlerts() ? "checked" : ""%>
                                    name="DisplayOrderAlerts">
                                <strong>Display Order Alerts</strong>
                            </td>
                            <td>Display completed order alerts.</td>
                        </tr>
                        <tr>
                            <td>
                                <INPUT type="checkbox"
                                    <%=TradeConfig.getLongRun() ? "checked" : ""%>
                                    name="EnableLongRun">
                                <strong>Enable long run support</strong>
                            </td>
                            <td>Enable long run support by disabling the show all orders query
                                performed on the Account page.</td>
                        </tr>
                        <tr>
                            <td>
                                <INPUT type="checkbox"
                                    <%=TradeConfig.getActionTrace() ? "checked" : ""%>
                                    name="EnableActionTrace">
                                <strong>Enable operation trace</strong><br>
                                <INPUT type="checkbox"
                                    <%=TradeConfig.getTrace() ? "checked" : ""%>
                                    name="EnableTrace">
                                <strong>Enable full trace</strong>
                            </td>
                            <td>Enable DayTrader processing trace messages.</td>
                        </tr>
                        <tr>
                            <td colspan="2" style="text-align: right;">
                                <INPUT type="submit" value="Update Config">
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </FORM>

    </main>

    <footer class="dt-footer">
        DayTrader
    </footer>
</body>
</html>
