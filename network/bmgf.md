---
layout:    minimal
title:     Bill & Melinda Gates Foundation
subtitle:  Committed Grants
ext-js:    ["//code.jquery.com/jquery-3.5.1.js", "//cdn.datatables.net/1.10.24/js/jquery.dataTables.min.js"]
ext-css:   ["//cdn.datatables.net/1.10.24/css/jquery.dataTables.min.css"]
js:        ["/assets/js/table-bmgf.js"]
css:       ["/assets/css/table-bmgf.css"]
---

<h1>Bill & Melinda Gates Foundation</h1>

<h2>Committed Grants</h2>

<br/>

<div class="datatable">
  <table id="bmgf" class="display compact" style="width:100%">
    <thead>
      <tr>
        <th>ID</th>
        <th>Grantee</th>
        <th>Purpose</th>
        <th>Division</th>
        <th>Date</th>
        <th>Duration</th>
        <th>Amount</th>
        <th>City/State/Country</th>
        <th>Region</th>
        <th>Topic</th>
      </tr>
    </thead>
    <tbody>
    {% for grant in site.data.bmgf %}
      <tr>
        <td>{{ grant.id }}</td>
    {%- if grant.website -%}
        <td><a href="{{ grant.website }}">{{ grant.grantee }}</a></td>
    {%- else -%}
        <td>{{ grant.grantee }}</td>
    {%- endif -%}
        <td>{{ grant.purpose }}</td>
        <td>{{ grant.divison }}</td>
        <td>{{ grant.date }}</td>
        <td>{{ grant.duration }}</td>
        <td>{{ grant.amount }}</td>
        <td>{{ grant.city }}/{{ grant.state }}/{{ grant.country }}</td>
        <td>{{ grant.region }}</td>
        <td>{{ grant.topic }}</td>
      </tr>
    {% endfor %}
    </tbody>
  </table>
</div>
