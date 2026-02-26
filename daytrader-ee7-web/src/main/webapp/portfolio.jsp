<!DOCTYPE html>
<%@ page
    import="java.util.Collection,
            java.util.Iterator,
            java.util.HashMap,
            java.math.BigDecimal,com.ibm.websphere.samples.daytrader.entities.HoldingDataBean,com.ibm.websphere.samples.daytrader.entities.OrderDataBean,com.ibm.websphere.samples.daytrader.entities.QuoteDataBean,com.ibm.websphere.samples.daytrader.util.Log,com.ibm.websphere.samples.daytrader.util.FinancialUtils"
    session="true" isThreadSafe="true" isErrorPage="false"%>
<jsp:useBean id="results" scope="request" type="java.lang.String" />
<jsp:useBean id="holdingDataBeans" type="java.util.Collection<?>"
    scope="request" />
<jsp:useBean id="quoteDataBeans" type="java.util.Collection<?>"
    scope="request" />
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DayTrader Portfolio</title>
    <link rel="stylesheet" href="style.css" type="text/css">
    <link rel="shortcut icon" href="./favicon.ico">
</head>
<body>
    <nav class="dt-nav">
        <a href="app?action=home" class="dt-brand">
            <span class="dt-brand-icon">DT</span>
            DayTrader
        </a>
        <ul class="dt-nav-links">
            <li><a href="app?action=home">Home</a></li>
            <li><a href="app?action=account">Account</a></li>
            <li><a href="app?action=mksummary">Market Summary</a></li>
            <li><a href="app?action=portfolio" class="active">Portfolio</a></li>
            <li><a href="app?action=quotes&amp;symbols=s:0,s:1,s:2,s:3,s:4">Quotes/Trade</a></li>
            <li><a href="app?action=logout">Logout</a></li>
        </ul>
    </nav>

    <main class="dt-main">
        <%
            Collection<?> closedOrders = (Collection<?>) request.getAttribute("closedOrders");
            if ((closedOrders != null) && (closedOrders.size() > 0)) {
        %>
        <div class="dt-alert dt-alert-warning">
            <strong>Order Alert:</strong> The following order(s) have completed.
            <table class="table" style="margin-top:0.5rem;">
                <thead>
                    <tr class="tableHeader">
                        <td>Order ID</td><td>Status</td><td>Opened</td><td>Completed</td><td>Fee</td><td>Type</td><td>Symbol</td><td>Quantity</td>
                    </tr>
                </thead>
                <tbody>
                <%
                    Iterator<?> it = closedOrders.iterator();
                    while (it.hasNext()) {
                        OrderDataBean closedOrderData = (OrderDataBean) it.next();
                %>
                    <tr class="tableOddRow">
                        <td><%=closedOrderData.getOrderID()%></td>
                        <td><%=closedOrderData.getOrderStatus()%></td>
                        <td><%=closedOrderData.getOpenDate()%></td>
                        <td><%=closedOrderData.getCompletionDate()%></td>
                        <td><%=closedOrderData.getOrderFee()%></td>
                        <td><%=closedOrderData.getOrderType()%></td>
                        <td><%=FinancialUtils.printQuoteLink(closedOrderData.getSymbol())%></td>
                        <td><%=closedOrderData.getQuantity()%></td>
                    </tr>
                <%
                    }
                %>
                </tbody>
            </table>
        </div>
        <%
            }
        %>

        <%
            // Pre-compute totals for the hero
            Iterator<?> it2pre = quoteDataBeans.iterator();
            HashMap<Object,Object> quoteMapPre = new HashMap<Object,Object>();
            while (it2pre.hasNext()) { QuoteDataBean qd = (QuoteDataBean) it2pre.next(); quoteMapPre.put(qd.getSymbol(), qd); }
            BigDecimal preTotalBasis = new BigDecimal(0.0), preTotalValue = new BigDecimal(0.0), preTotalGain = new BigDecimal(0.0);
            for (Object hObj : holdingDataBeans) {
                try {
                    HoldingDataBean hd = (HoldingDataBean) hObj;
                    QuoteDataBean qd = (QuoteDataBean) quoteMapPre.get(hd.getQuoteID());
                    if (qd == null) continue;
                    BigDecimal b = hd.getPurchasePrice().multiply(new BigDecimal(hd.getQuantity()));
                    BigDecimal mv = qd.getPrice().multiply(new BigDecimal(hd.getQuantity()));
                    preTotalBasis = preTotalBasis.add(b); preTotalValue = preTotalValue.add(mv);
                    preTotalGain = preTotalGain.add(mv.subtract(b));
                } catch (Exception ex) {}
            }
        %>

        <!-- Portfolio Hero -->
        <div class="dt-hero">
            <div class="dt-hero-title">Portfolio</div>
            <div class="dt-hero-grid">
                <div class="dt-hero-item">
                    <div class="dt-hero-label">Market Value</div>
                    <div class="dt-hero-value">$<%=preTotalValue%></div>
                    <div class="dt-hero-sub">Current holdings value</div>
                </div>
                <div class="dt-hero-item">
                    <div class="dt-hero-label">Total Gain / Loss</div>
                    <div class="dt-hero-value <%= preTotalGain.doubleValue() >= 0 ? "gain" : "loss" %>"><%=FinancialUtils.printGainHTML(preTotalGain)%></div>
                    <div class="dt-hero-sub"><%=FinancialUtils.printGainPercentHTML(FinancialUtils.computeGainPercent(preTotalValue, preTotalBasis))%> vs. cost basis</div>
                </div>
                <div class="dt-hero-item">
                    <div class="dt-hero-label">Cost Basis</div>
                    <div class="dt-hero-value" style="font-size:1.5rem;">$<%=preTotalBasis%></div>
                    <div class="dt-hero-sub">Total invested</div>
                </div>
                <div class="dt-hero-item">
                    <div class="dt-hero-label">Positions</div>
                    <div class="dt-hero-value" style="font-size:1.5rem;"><%=holdingDataBeans.size()%></div>
                    <div class="dt-hero-sub">Holdings</div>
                </div>
            </div>
        </div>

        <div class="dt-card">
            <div class="dt-card-header">
                <h3>Holdings</h3>
                <div style="display:flex;align-items:center;gap:0.75rem;">
                    <span class="dt-badge dt-badge-blue"><%=holdingDataBeans.size()%> positions</span>
                    <span style="font-size:0.75rem;color:var(--text-muted);"><%=new java.util.Date()%></span>
                </div>
            </div>
            <div style="overflow-x:auto;">
                <table class="table">
                    <thead>
                        <tr class="tableHeader">
                            <td>ID</td><td>Purchase Date</td><td>Symbol</td><td>Qty</td>
                            <td>Cost/Share</td><td>Current</td><td>Basis</td><td>Mkt Value</td>
                            <td>Gain / Loss</td><td>Action</td>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Iterator<?> it2 = quoteDataBeans.iterator();
                            HashMap<Object,Object> quoteMap = new HashMap<Object,Object>();
                            while (it2.hasNext()) { QuoteDataBean quoteData = (QuoteDataBean) it2.next(); quoteMap.put(quoteData.getSymbol(), quoteData); }
                            it2 = holdingDataBeans.iterator();
                            BigDecimal totalGain = new BigDecimal(0.0), totalBasis = new BigDecimal(0.0), totalValue = new BigDecimal(0.0);
                            int rowCount = 0;
                            try {
                                while (it2.hasNext()) {
                                    HoldingDataBean holdingData = (HoldingDataBean) it2.next();
                                    QuoteDataBean quoteData = (QuoteDataBean) quoteMap.get(holdingData.getQuoteID());
                                    BigDecimal basis = holdingData.getPurchasePrice().multiply(new BigDecimal(holdingData.getQuantity()));
                                    BigDecimal marketValue = quoteData.getPrice().multiply(new BigDecimal(holdingData.getQuantity()));
                                    totalBasis = totalBasis.add(basis); totalValue = totalValue.add(marketValue);
                                    BigDecimal gain = marketValue.subtract(basis);
                                    totalGain = totalGain.add(gain);
                                    BigDecimal gainPercent = null;
                                    if (basis.doubleValue() == 0.0) {
                                        gainPercent = new BigDecimal(0.0);
                                        Log.error("portfolio.jsp: Holding with zero basis. holdingID=" + holdingData.getHoldingID() + " symbol=" + holdingData.getQuoteID() + " purchasePrice=" + holdingData.getPurchasePrice());
                                    } else gainPercent = marketValue.divide(basis, BigDecimal.ROUND_HALF_UP).subtract(new BigDecimal(1.0)).multiply(new BigDecimal(100.0));
                                    boolean rowGain = gain.doubleValue() >= 0;
                        %>
                        <tr class="<%= (rowCount++ % 2 == 0) ? "tableOddRow" : "tableEvenRow" %> <%= rowGain ? "dt-row-gain" : "dt-row-loss" %>">
                            <td style="color:var(--text-muted);"><%=holdingData.getHoldingID()%></td>
                            <td style="color:var(--text-muted);font-size:0.75rem;white-space:nowrap;"><%=holdingData.getPurchaseDate()%></td>
                            <td style="font-weight:700;"><%=FinancialUtils.printQuoteLink(holdingData.getQuoteID())%></td>
                            <td class="font-mono"><%=holdingData.getQuantity()%></td>
                            <td class="font-mono">$<%=holdingData.getPurchasePrice()%></td>
                            <td class="font-mono" style="font-weight:600;">$<%=quoteData.getPrice()%></td>
                            <td class="font-mono">$<%=basis%></td>
                            <td class="font-mono" style="font-weight:600;">$<%=marketValue%></td>
                            <td class="font-mono" style="font-weight:700;"><%=FinancialUtils.printGainHTML(gain)%></td>
                            <td><a href="app?action=sell&amp;holdingID=<%=holdingData.getHoldingID()%>" class="dt-btn dt-btn-danger dt-btn-sm">Sell</a></td>
                        </tr>
                        <%
                                }
                            } catch (Exception e) { Log.error("portfolio.jsp: error displaying user holdings", e); }
                        %>
                        <tr style="background:#0d1628;font-weight:700;border-top:2px solid var(--border-color);">
                            <td colspan="6" style="text-align:right;color:var(--text-muted);font-size:0.6875rem;text-transform:uppercase;letter-spacing:0.05em;">Portfolio Total</td>
                            <td class="font-mono">$<%=totalBasis%></td>
                            <td class="font-mono">$<%=totalValue%></td>
                            <td class="font-mono" colspan="2" style="color:<%= totalGain.doubleValue() >= 0 ? "var(--gain-color)" : "var(--loss-color)" %>;">
                                <%=FinancialUtils.printGainHTML(totalGain)%>
                                <span style="font-size:0.75rem;margin-left:0.25rem;"><%=FinancialUtils.printGainPercentHTML(FinancialUtils.computeGainPercent(totalValue, totalBasis))%></span>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="dt-card">
            <div class="dt-card-header"><h3>Quick Quote</h3></div>
            <form action="" style="display:flex;gap:0.75rem;align-items:center;flex-wrap:wrap;">
                <input style="flex:1;min-width:200px;" type="text" name="symbols" value="s:0, s:1, s:2, s:3, s:4">
                <input type="submit" name="action" value="quotes">
            </form>
            <p style="margin:0.75rem 0 0;font-size:0.75rem;">Click any <a href="docs/glossary.html">symbol</a> above for a live quote or to place a trade.</p>
        </div>
    </main>

    <footer class="dt-footer">
        Apache DayTrader Performance Benchmark Sample
    </footer>
</body>
</html>
