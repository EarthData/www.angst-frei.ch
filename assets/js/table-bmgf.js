$(document).ready( function () {
  var table = $('#bmgf').DataTable( {
    "columnDefs": [
      { "type": "num", "targets": [5] },
      { "type": "num", "targets": [6] },
      { "type": "date", "targets": [4] }
    ]
  } );
} );
