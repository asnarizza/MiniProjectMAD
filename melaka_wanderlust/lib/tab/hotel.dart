import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HotelTab extends StatelessWidget {
  // URL you want to open
  final String _url = 'https://www.booking.com/city/my/melaka.html?aid=306395;'
      'label=my-melaka-kUJSIXFN7vymwTlzgw6hFQS528846144605:pl:ta:p1380:p2:ac:'
      'ap:neg:fi:tiaud-2201527651392:kwd-711832826:lp1029508:li:dec:dm:ppccp='
      'UmFuZG9tSVYkc2RlIyh9YZVcNNsENnH02-pWD53qm9c;ws=&gad_source=1&gclid='
      'CjwKCAiA-bmsBhAGEiwAoaQNmg3j23I2DDLE728ZeeyleCLB5yc57DHLLjIB_'
      'Hje563VEmskICjB8hoC4JoQAvD_BwE';

  // Function to launch URL
  void _launchURL() async {
    if (!await launch(_url)) throw 'Could not launch $_url';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 200, // Adjust the width as needed
              height: 200, // Adjust the height as needed
              child: Image.asset('lib/images/traveler.png'),
            ),
            SizedBox(height: 20),
            Text(
              'Looking for a place to stay?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),// Spacing
            ElevatedButton(
              onPressed: _launchURL,
              child: Text(
                'Click Here !',
                style: TextStyle(
                  fontSize: 18, // Larger text size
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.orange, // Button color
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
