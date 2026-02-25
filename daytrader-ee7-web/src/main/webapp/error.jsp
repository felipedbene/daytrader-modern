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
<%@ page
    import="java.io.StringWriter,
                 java.io.PrintWriter"%>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DayTrader Error</title>
    <link rel="stylesheet" href="style.css" type="text/css">
    <link rel="shortcut icon" href="./favicon.ico">
</head>
<body>
    <nav class="dt-nav">
        <a href="index.html" class="dt-brand">
            <span class="dt-brand-icon">DT</span>
            DayTrader
        </a>
    </nav>

    <main class="dt-main">
        <div class="dt-card">
            <div class="dt-card-header">
                <h3>Error</h3>
            </div>
            <div class="dt-alert dt-alert-danger">
                <strong>An error has occurred during DayTrader processing.</strong>
                <p>The stack trace detailing the error follows.</p>
                <p><strong>Please consult the application server error logs for further details.</strong></p>
            </div>
            <div style="padding:1rem;font-family:var(--font-mono);font-size:0.8125rem;color:var(--text-secondary);overflow-x:auto;">
                <FONT size="-1"> <%
     String message = null;
     int status_code = -1;
     String exception_info = null;
     String url = null;

     try {
         Exception theException = null;
         Integer status = null;

         //these attribute names are specified by Servlet 2.2
         message = (String) request.getAttribute("javax.servlet.error.message");
         status = ((Integer) request.getAttribute("javax.servlet.error.status_code"));
         theException = (Exception) request.getAttribute("javax.servlet.error.exception");
         url = (String) request.getAttribute("javax.servlet.error.request_uri");

         // convert the stack trace to a string
         StringWriter sw = new StringWriter();
         PrintWriter pw = new PrintWriter(sw);
         theException.printStackTrace(pw);
         pw.flush();
         pw.close();

         if (message == null) {
             message = "not available";
         }

         if (status == null) {
             status_code = -1;
         } else {
             status_code = status.intValue();
         }

         exception_info = theException.toString();
         exception_info = exception_info + "<br>" + sw.toString();
         sw.close();

     } catch (Exception e) {
         e.printStackTrace();
     }

     out.println("<br><br><b>Processing request:</b>" + url);
     out.println("<br><b>StatusCode:</b> " + status_code);
     out.println("<br><b>Message:</b>" + message);
     out.println("<br><b>Exception:</b>" + exception_info);
 %>
                </FONT>
            </div>
        </div>
    </main>

    <footer class="dt-footer">
        Apache DayTrader Performance Benchmark Sample
    </footer>
</body>
</html>
