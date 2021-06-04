$(document).ready( function () {
  var table = $('#bmgf').DataTable( {
    "columnDefs": [
      {
        "targets": [ 2, 9 ],
        "visible": false,
        "searchable": true
      }
    ]
  } );
     
  $('#bmgf tbody').on('click', 'tr', function () {
    var data = table.row( this ).data();
    alert( 'Purpose: ' + data[2] + '\nTopic: ' + data[9] );
  } );

} );
