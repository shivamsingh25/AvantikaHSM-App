<?php $db = mysqli_connect('localhost', 'root', '', 'hsm'); ?>
<!DOCTYPE html>
<html>

<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>Admin &dash; Avantika HSM | Avantika University</title>
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1.0, user-scalable=no">
  <link rel="icon" type="image/png" href="images/favicon/favicon.ico">
  <link rel="stylesheet" type="text/css" media="screen" href="css/main.css">
  <script src="js/main.js"></script>

  <script src="js/jquery.min.js"></script>

  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">

  <!-- Compiled and minified CSS -->
  <link rel="stylesheet" href="/css/materialize.min.css">

  <!-- Compiled and minified JavaScript -->
  <script src="js/materialize.min.js"></script>
  <script src="js/Chart.min.js"></script>
  <style>
  </style>
</head>

<body onload="aupreloader()">
  <div id="auprogress">
    <div class="progress orange darken-2">
      <div class="indeterminate grey"></div>
    </div>
    <div class="center-align">Please wait</div>
  </div>
  <div id="pagecontent">

    <div id="navbartop">
      <div id="logo-hsm"><a href="#" data-target="slide-out" class="navleft sidenav-trigger"><b><i class="material-icons left">menu</i>Avantika<span id="span-hsm">HSM<span></b></a></div>
      <a id="logout-bar" class="navright" href="#">Logout</a>
    </div>

    <ul id="slide-out" class="sidenav">
      <li>
        <div class="user-view">
          <div class="background"></div>
          <a href="#user"><img class="circle" src="https://lh5.googleusercontent.com/-a1a7VfOAjro/AAAAAAAAAAI/AAAAAAAAAAc/3EkdxlqiZJE/photo.jpg"></a>
          <a href="#name"><span class="white-text name">Shivam Singh</span></a>
          <a href="#email"><span class="white-text email">shivam.singh78925@gmail.com</span></a>
        </div>
      </li>
      <li><a class="subheader">Admin - HSM | Avantika University</a></li>
      <li><a href="javascript:secdeptadminjs()" id="securityadminpanel" class="waves-effect"><i class="material-icons">security</i>Security</a></li>
      <li><a href="javascript:hkdeptadminjs()" class="waves-effect"><i class="material-icons">person</i>Housekeeping</a></li>
      <li><a href="#!" class="waves-effect"><i class="material-icons">power_settings_new</i>Logout</a></li>
    </ul>
    <div class="main-theme center-align">
      <div id="hsmadmindash" class="center center-align">
        <h4>Welcome to Avantika HSM</h4>
        <img src="images/hsmsubmit.svg" id="svgimg">
        <h5>Please choose HSM Department to show dashboard.</h5>
      </div>
      <div class="col s12 m12" id="hkdeptadmin">
        <h4>Housekeeping/ HSM Service Requests count of last week</h4>
        <h6>Dates v/s Service Requests Count - Past 7 days data</h6>
        <canvas id="hsmService" width="300" height="100"></canvas>
        <script>
          <?php
          $today = date("Y-m-d");
          $today1 = date('Y-m-d', strtotime('-1 days'));
          $today2 = date('Y-m-d', strtotime('-2 days'));
          $today3 = date('Y-m-d', strtotime('-3 days'));
          $today4 = date('Y-m-d', strtotime('-4 days'));
          $today5 = date('Y-m-d', strtotime('-5 days'));
          $today6 = date('Y-m-d', strtotime('-6 days'));

          $query = "SELECT count(request_id) FROM `hsm_service_request` WHERE requested_date = '" . $today . "'";
          $countocc = mysqli_query($db, $query);
          $count = mysqli_fetch_assoc($countocc);
          $query1 = "SELECT count(request_id) FROM `hsm_service_request` WHERE requested_date = '" . $today1 . "'";
          $countocc = mysqli_query($db, $query1);
          $count1 = mysqli_fetch_assoc($countocc);
          $query2 = "SELECT count(request_id) FROM `hsm_service_request` WHERE requested_date = '" . $today2 . "'";
          $countocc = mysqli_query($db, $query2);
          $count2 = mysqli_fetch_assoc($countocc);
          $query3 = "SELECT count(request_id) FROM `hsm_service_request` WHERE requested_date = '" . $today3 . "'";
          $countocc = mysqli_query($db, $query3);
          $count3 = mysqli_fetch_assoc($countocc);
          $query4 = "SELECT count(request_id) FROM `hsm_service_request` WHERE requested_date = '" . $today4 . "'";
          $countocc = mysqli_query($db, $query4);
          $count4 = mysqli_fetch_assoc($countocc);
          $query5 = "SELECT count(request_id) FROM `hsm_service_request` WHERE requested_date = '" . $today5 . "'";
          $countocc = mysqli_query($db, $query5);
          $count5 = mysqli_fetch_assoc($countocc);
          $query6 = "SELECT count(request_id) FROM `hsm_service_request` WHERE requested_date = '" . $today6 . "'";
          $countocc = mysqli_query($db, $query6);
          $count6 = mysqli_fetch_assoc($countocc);


          $today = date("d");
          $today1 = date('d', strtotime('-1 days'));
          $today2 = date('d', strtotime('-2 days'));
          $today3 = date('d', strtotime('-3 days'));
          $today4 = date('d', strtotime('-4 days'));
          $today5 = date('d', strtotime('-5 days'));
          $today6 = date('d', strtotime('-6 days'));
          ?>
          var ctx = document.getElementById('hsmService').getContext('2d');
          var hsmService = new Chart(ctx, {
            type: 'bar',
            data: {
              labels: [<?php echo $today6 . ',' . $today5 . ',' . $today4 . ',' . $today3 . ',' . $today2 . ',' . $today1 . ',' . $today; ?>],
              datasets: [{
                label: 'HSM requests',
                data: [<?php echo $count6['count(request_id)'] . ',' . $count5['count(request_id)'] . ',' . $count4['count(request_id)'] . ',' . $count3['count(request_id)'] . ',' . $count2['count(request_id)'] . ',' . $count1['count(request_id)'] . ',' . $count['count(request_id)']; ?>],
                backgroundColor: [
                  'rgba(54, 162, 235, 0.2)',
                  'rgba(54, 162, 235, 0.2)',
                  'rgba(54, 162, 235, 0.2)',
                  'rgba(54, 162, 235, 0.2)',
                  'rgba(54, 162, 235, 0.2)',
                  'rgba(54, 162, 235, 0.2)',
                  'rgba(54, 162, 235, 0.2)'
                ],
                borderColor: [
                  'rgba(54, 162, 235, 1)',
                  'rgba(54, 162, 235, 1)',
                  'rgba(54, 162, 235, 1)',
                  'rgba(54, 162, 235, 1)',
                  'rgba(54, 162, 235, 1)',
                  'rgba(54, 162, 235, 1)',
                  'rgba(54, 162, 235, 1)'
                ],
                borderWidth: 1
              }]
            },
            options: {
              scales: {
                yAxes: [{
                  ticks: {
                    beginAtZero: true
                  }
                }]
              }
            }
          });
        </script>
        <center>
          <h4>Housekeeping Register Entries</h4>
        </center>
        <div class="occurrencecolumn col s12 m12">
          <ul class="collapsible">
            <?php
            $query = "SELECT * FROM `housekeeping_register` ORDER BY `id` DESC";
            if ($show = mysqli_query($db, $query)) {
              while ($fieldinfo = mysqli_fetch_assoc($show)) {
                echo '<li>';
                echo '<div class="collapsible-header"><i class="material-icons">assignment</i>' . $fieldinfo["place"] . ', Room: ' . $fieldinfo["room"] .' From: ' . date("d/m/y g:i A", strtotime($fieldinfo["start_time"])) . ', To: ' . date("d/m/y g:i A", strtotime($fieldinfo["end_time"])) . ', By: ' . $fieldinfo["staff_id"] . '</div>';
                echo '<div class="collapsible-body left-align"><span>Remarks: ' . $fieldinfo["remarks"] . '<hr>Verification Signature:</br><center><img class="center SignatureImage" src="' . $fieldinfo["verified_sign"] . '"></center></br>Signed time: ' . $fieldinfo["verified_timestamp"] . '</span></div>';
                echo '</li>';
              }
            }
            ?>
          </ul>
        </div>
      </div>
      <div class="col s12 m12" id="secdeptadmin">
        <h4>Security Watchlist and Occurrence count of last week</h4>
        <h6>Dates v/s Occurrence Count - Past 7 days data</h6>
        <canvas id="secOcc" width="300" height="100"></canvas>
        <script>
          <?php
          $today = date("Y-m-d");
          $today1 = date('Y-m-d', strtotime('-1 days'));
          $today2 = date('Y-m-d', strtotime('-2 days'));
          $today3 = date('Y-m-d', strtotime('-3 days'));
          $today4 = date('Y-m-d', strtotime('-4 days'));
          $today5 = date('Y-m-d', strtotime('-5 days'));
          $today6 = date('Y-m-d', strtotime('-6 days'));

          $query = "SELECT count(id) FROM `SEC_Occurrence` WHERE date_time LIKE '" . $today . "%'";
          $countocc = mysqli_query($db, $query);
          $count = mysqli_fetch_assoc($countocc);
          $query1 = "SELECT count(id) FROM `SEC_Occurrence` WHERE date_time LIKE '" . $today1 . "%'";
          $countocc = mysqli_query($db, $query1);
          $count1 = mysqli_fetch_assoc($countocc);
          $query2 = "SELECT count(id) FROM `SEC_Occurrence` WHERE date_time LIKE '" . $today2 . "%'";
          $countocc = mysqli_query($db, $query2);
          $count2 = mysqli_fetch_assoc($countocc);
          $query3 = "SELECT count(id) FROM `SEC_Occurrence` WHERE date_time LIKE '" . $today3 . "%'";
          $countocc = mysqli_query($db, $query3);
          $count3 = mysqli_fetch_assoc($countocc);
          $query4 = "SELECT count(id) FROM `SEC_Occurrence` WHERE date_time LIKE '" . $today4 . "%'";
          $countocc = mysqli_query($db, $query4);
          $count4 = mysqli_fetch_assoc($countocc);
          $query5 = "SELECT count(id) FROM `SEC_Occurrence` WHERE date_time LIKE '" . $today5 . "%'";
          $countocc = mysqli_query($db, $query5);
          $count5 = mysqli_fetch_assoc($countocc);
          $query6 = "SELECT count(id) FROM `SEC_Occurrence` WHERE date_time LIKE '" . $today6 . "%'";
          $countocc = mysqli_query($db, $query6);
          $count6 = mysqli_fetch_assoc($countocc);


          $today = date("d");
          $today1 = date('d', strtotime('-1 days'));
          $today2 = date('d', strtotime('-2 days'));
          $today3 = date('d', strtotime('-3 days'));
          $today4 = date('d', strtotime('-4 days'));
          $today5 = date('d', strtotime('-5 days'));
          $today6 = date('d', strtotime('-6 days'));
          ?>
          //console.log(<?php echo $today6 . ',' . $today5 . ',' . $today4 . ',' . $today3 . ',' . $today2 . ',' . $today1 . ',' . $today; ?>);
          var ctx = document.getElementById('secOcc').getContext('2d');
          var secOcc = new Chart(ctx, {
            type: 'bar',
            data: {
              labels: [<?php echo $today6 . ',' . $today5 . ',' . $today4 . ',' . $today3 . ',' . $today2 . ',' . $today1 . ',' . $today; ?>],
              datasets: [{
                label: 'Security Occurrence Count',
                data: [<?php echo $count6['count(id)'] . ',' . $count5['count(id)'] . ',' . $count4['count(id)'] . ',' . $count3['count(id)'] . ',' . $count2['count(id)'] . ',' . $count1['count(id)'] . ',' . $count['count(id)']; ?>],
                backgroundColor: [
                  'rgba(255, 0, 0, 0.4)',
                  'rgba(255, 0, 0, 0.4)',
                  'rgba(255, 0, 0, 0.4)',
                  'rgba(255, 0, 0, 0.4)',
                  'rgba(255, 0, 0, 0.4)',
                  'rgba(255, 0, 0, 0.4)',
                  'rgba(255, 0, 0, 0.4)'
                ],
                borderColor: [
                  'rgba(255, 0, 0, 0.6)',
                  'rgba(255, 0, 0, 0.6)',
                  'rgba(255, 0, 0, 0.6)',
                  'rgba(255, 0, 0, 0.6)',
                  'rgba(255, 0, 0, 0.6)',
                  'rgba(255, 0, 0, 0.6)',
                  'rgba(255, 0, 0, 0.6)'
                ],
                borderWidth: 1
              }]
            },
            options: {
              scales: {
                yAxes: [{
                  ticks: {
                    beginAtZero: true
                  }
                }]
              }
            }
          });
        </script>
        <center>
          <h4>Occurrence Reports</h4>
        </center>
        <div class="occurrencecolumn col s12 m12">
          <ul class="collapsible">
            <?php
            $query = "SELECT * FROM `SEC_Occurrence` ORDER BY `id` DESC";
            if ($show = mysqli_query($db, $query)) {
              while ($fieldinfo = mysqli_fetch_assoc($show)) {
                echo '<li>';
                echo '<div class="collapsible-header"><i class="material-icons">remove_red_eye</i>' . $fieldinfo["occurrence"] . ' at ' . date("d/m/y g:i A", strtotime($fieldinfo["date_time"])) . ', Reported at ' . date("d/m/y g:i A", strtotime($fieldinfo["entry"])) . ', By: ' . $fieldinfo["reported_by"] . '</div>';
                echo '<div class="collapsible-body left-align"><span>Occurrence: ' . $fieldinfo["occurrence"] . '</br>Occurrence Date/Time: ' . date("d/m/y g:i A", strtotime($fieldinfo["date_time"])) . '</br>Reported by: ' . $fieldinfo["reported_by"] . '</br> Reported Date/Time: ' . date("d/m/y g:i A", strtotime($fieldinfo["entry"])) . '<hr>Name: ' . $fieldinfo["name"] . '</br>Department/ Category: ' . $fieldinfo["department"] . '</br>Student Involved: ' . $fieldinfo["student_involved"] . '</br>Staff Involved: ' . $fieldinfo["staff_involved"] . '</br>Remarks: ' . $fieldinfo["remarks"] . '</span></div>';
                echo '</li>';
              }
            }
            ?>
          </ul>
        </div>
      </div>
    </div>

  </div>
  <script>
    (function($) {
      $(function() {

        $('.sidenav').sidenav();

      }); // end of document ready
    })(jQuery); // end of jQuery name space

    $(document).ready(function() {
      $('.collapsible').collapsible();
    });
  </script>
</body>

</html>