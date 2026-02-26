/**
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
 */
package com.ibm.websphere.samples.daytrader.web;

import java.io.IOException;
import java.security.Principal;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

/**
 * Bridges OIDC authentication (Liberty container-level) to DayTrader's
 * session-based authentication model.
 *
 * When Liberty successfully authenticates a user via OIDC (Authentik),
 * getUserPrincipal() returns the OIDC principal whose name is the
 * preferred_username claim. This filter maps that principal to the
 * DayTrader session attribute "uidBean" so the rest of the application
 * treats the user as logged in without requiring a second login form.
 *
 * Requirement: the Authentik user's preferred_username must match a
 * DayTrader userId (e.g. "uid:0"). For a demo, one Authentik user named
 * "uid:0" is sufficient.
 *
 * Logout is handled automatically: TradeServletAction.doLogout() already
 * calls req.logout(), which invalidates the OIDC principal at the
 * container level.
 */
@WebFilter("/*")
public class OidcSessionFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
                         FilterChain chain) throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        Principal principal = req.getUserPrincipal();

        if (principal != null) {
            HttpSession session = req.getSession(false);
            if (session == null || session.getAttribute("uidBean") == null) {
                HttpSession newSession = req.getSession(true);
                newSession.setAttribute("uidBean", principal.getName());
                newSession.setAttribute("sessionCreationDate", new java.util.Date());
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void init(FilterConfig filterConfig) {}

    @Override
    public void destroy() {}
}
