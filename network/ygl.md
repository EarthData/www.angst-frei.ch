---
layout:    minimal
title:     Yound Global Leaders
subtitle:  Community
ext-js:    ["//code.jquery.com/jquery-3.5.1.js", "//cdn.datatables.net/1.10.24/js/jquery.dataTables.min.js"]
ext-css:   ["//cdn.datatables.net/1.10.24/css/jquery.dataTables.min.css"]
js:        ["/assets/js/table-ygl.js"]
css:       ["/assets/css/table-ygl.css"]
---

<h1>Yound Global Leaders</h1>

<h2>Community</h2>
 
<p>Quelle: <a href="https://www.younggloballeaders.org/">The Forum of Young Global Leaders</a>

<div class="datatable">
  <table id="ygl" class="display compact" style="width:100%">
    <thead>
      <tr>
        <th>Name</th>
        <th>Meta</th>
      </tr>
    </thead>
    <tbody>
    {% for leader in site.data.ygl %}
      <tr>
        <td>{{ leader.name }}</td>
        <td>{{ leader.meta }}</td>
      </tr>
    {% endfor %}
    </tbody>
  </table>
</div>
