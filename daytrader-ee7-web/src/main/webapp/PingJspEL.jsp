<!DOCTYPE html>
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
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>PingJspEL</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
    <%@ page
        import="com.ibm.websphere.samples.daytrader.util.TradeConfig,com.ibm.websphere.samples.daytrader.entities.QuoteDataBean"
        session="false"%>

    <%!int hitCount = 0;
    String initTime = new java.util.Date().toString();%>

    <%
        int someint1 = TradeConfig.rndInt(100) + 1;
        pageContext.setAttribute("someint1", new Integer(someint1));
        int someint2 = TradeConfig.rndInt(100) + 1;
        pageContext.setAttribute("someint2", new Integer(someint2));
        float somefloat1 = TradeConfig.rndFloat(100) + 1.0f;
        pageContext.setAttribute("somefloat1", new Float(somefloat1));
        float somefloat2 = TradeConfig.rndFloat(100) + 1.0f;
        pageContext.setAttribute("somefloat2", new Float(somefloat2));

        QuoteDataBean quoteData1 = QuoteDataBean.getRandomInstance();
        pageContext.setAttribute("quoteData1", quoteData1);
        QuoteDataBean quoteData2 = QuoteDataBean.getRandomInstance();
        pageContext.setAttribute("quoteData2", quoteData2);
        QuoteDataBean quoteData3 = QuoteDataBean.getRandomInstance();
        pageContext.setAttribute("quoteData3", quoteData3);
        QuoteDataBean quoteData4 = QuoteDataBean.getRandomInstance();
        pageContext.setAttribute("quoteData4", quoteData4);

        QuoteDataBean quoteData[] = new QuoteDataBean[4];
        quoteData[0] = quoteData1;
        quoteData[1] = quoteData2;
        quoteData[2] = quoteData3;
        quoteData[3] = quoteData4;
        pageContext.setAttribute("quoteData", quoteData);
    %>

    <div class="dt-main-narrow" style="margin-top:2rem;">
        <div class="dt-card">
            <div class="dt-card-header">
                <h2>Ping JSP EL</h2>
                <span class="dt-badge dt-badge-green">OK</span>
            </div>
            <div class="dt-stats-grid" style="grid-template-columns: 1fr 1fr;">
                <div class="dt-stat">
                    <div class="dt-stat-label">Init Time</div>
                    <div class="dt-stat-value" style="font-size:0.875rem;"><%=initTime%></div>
                </div>
                <div class="dt-stat">
                    <div class="dt-stat-label">Hit Count</div>
                    <div class="dt-stat-value"><%=hitCount++%></div>
                </div>
            </div>
        </div>

        <div class="dt-card">
            <div class="dt-card-header"><h3>Variables</h3></div>
            <div class="dt-stats-grid" style="grid-template-columns: 1fr 1fr 1fr 1fr;">
                <div class="dt-stat">
                    <div class="dt-stat-label">someint1</div>
                    <div class="dt-stat-value"><%=someint1%></div>
                </div>
                <div class="dt-stat">
                    <div class="dt-stat-label">someint2</div>
                    <div class="dt-stat-value"><%=someint2%></div>
                </div>
                <div class="dt-stat">
                    <div class="dt-stat-label">somefloat1</div>
                    <div class="dt-stat-value"><%=somefloat1%></div>
                </div>
                <div class="dt-stat">
                    <div class="dt-stat-label">somefloat2</div>
                    <div class="dt-stat-value"><%=somefloat2%></div>
                </div>
            </div>
        </div>

        <div class="dt-card">
            <div class="dt-card-header"><h3>EL Expression Tests</h3></div>
            <table class="dt-test-table">
                <thead>
                    <tr>
                        <th>EL Type</th>
                        <th>EL Expression</th>
                        <th>Result</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>Integer Arithmetic</td>
                        <td style="font-family:var(--font-mono);font-size:0.8125rem;">\${someint1 + someint2 - someint1 * someint2 mod someint1}</td>
                        <td style="font-family:var(--font-mono);">${someint1 + someint2 - someint1 * someint2 mod someint1}</td>
                    </tr>
                    <tr>
                        <td>Floating Point Arithmetic</td>
                        <td style="font-family:var(--font-mono);font-size:0.8125rem;">\${somefloat1 + somefloat2 - somefloat1 * somefloat2 / somefloat1}</td>
                        <td style="font-family:var(--font-mono);">${somefloat1 + somefloat2 - somefloat1 * somefloat2 / somefloat1}</td>
                    </tr>
                    <tr>
                        <td>Logical Operations</td>
                        <td style="font-family:var(--font-mono);font-size:0.8125rem;">\${(someint1 &lt; someint2) &amp;&amp; (someint1 &lt;= someint2) || (someint1 == someint2) &amp;&amp; !Boolean.FALSE}</td>
                        <td style="font-family:var(--font-mono);">${(someint1 < someint2) && (someint1 <= someint2) || (someint1 == someint2) && !Boolean.FALSE}</td>
                    </tr>
                    <tr>
                        <td>Indexing Operations</td>
                        <td style="font-family:var(--font-mono);font-size:0.8125rem;">
                            \${quoteData3.symbol}<br/>
                            \${quoteData[2].symbol}<br/>
                            \${quoteData4["symbol"]}<br/>
                            \${header["host"]}<br/>
                            \${header.host}
                        </td>
                        <td style="font-family:var(--font-mono);">
                            ${quoteData3.symbol}<br/>
                            ${quoteData[1].symbol}<br/>
                            ${quoteData4["symbol"]}<br/>
                            ${header["host"]}<br/>
                            ${header.host}
                        </td>
                    </tr>
                    <tr>
                        <td>Variable Scope Tests</td>
                        <td style="font-family:var(--font-mono);font-size:0.8125rem;">
                            \${(quoteData3 == null) ? "null" : quoteData3}<br/>
                            \${(noSuchVariableAtAnyScope == null) ? "null" : noSuchVariableAtAnyScope}
                        </td>
                        <td style="font-family:var(--font-mono);">
                            ${(quoteData3 == null) ? "null" : quoteData3}<br/>
                            ${(noSuchVariableAtAnyScope == null) ? "null" : noSuchVariableAtAnyScope}
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
