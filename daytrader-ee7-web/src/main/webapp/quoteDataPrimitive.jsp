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
    <meta http-equiv="pragma" content="no-cache">
    <title>Quote Data Primitive (PingServlet2Session2Entity2JSP)</title>
    <link rel="stylesheet" href="style.css" type="text/css">
</head>
<body>
    <%@ page
        import="com.ibm.websphere.samples.daytrader.entities.QuoteDataBean,com.ibm.websphere.samples.daytrader.util.FinancialUtils"
        session="false" isThreadSafe="true" isErrorPage="false"%>
    <%!int hitCount = 0;
    String initTime = new java.util.Date().toString();%>
    <%
        QuoteDataBean quoteData = (QuoteDataBean) request.getAttribute("quoteData");
    %>
    <main class="dt-main">
        <div class="dt-card">
            <div class="dt-card-header">
                <h3>Quote Data Primitive (PingServlet2Session2EntityJSP)</h3>
            </div>
            <p style="color:var(--text-secondary);">Init time: <%=initTime%></p>
            <%
                hitCount++;
            %>
            <p><strong>Hit Count: <%=hitCount%></strong></p>
            <hr>
            <p>Quote Information</p>
            <%=quoteData.toHTML()%>
        </div>
    </main>
</body>
</html>
