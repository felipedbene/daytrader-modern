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
<meta http-equiv="pragma" content="no-cache">
<title>PingJsp</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
    <%!int hitCount = 0;
    String initTime = new java.util.Date().toString();%>
    <%hitCount++;%>
    <div class="dt-main-narrow" style="margin-top:2rem;">
        <div class="dt-card">
            <div class="dt-card-header">
                <h2>Ping JSP</h2>
                <span class="dt-badge dt-badge-green">OK</span>
            </div>
            <div class="dt-stats-grid" style="grid-template-columns: 1fr 1fr;">
                <div class="dt-stat">
                    <div class="dt-stat-label">Init Time</div>
                    <div class="dt-stat-value" style="font-size:0.875rem;"><%=initTime%></div>
                </div>
                <div class="dt-stat">
                    <div class="dt-stat-label">Hit Count</div>
                    <div class="dt-stat-value"><%=hitCount%></div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
