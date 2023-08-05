import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class TermsandConditions extends StatelessWidget {
  const TermsandConditions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Terms and Conditions',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(58, 150, 255, 1),
        iconTheme: IconThemeData(color: Colors.white, size: 35.0),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "User Eligibility:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            Text(
              "The App is intended for use by students of the university only. By using the App, you confirm that you are a student of the university and are of legal age to enter into a binding contract in your jurisdiction.",
            ),
            SizedBox(height: 10),
            Text(
              "User Conduct:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            Text(
              "Users are solely responsible for their conduct while using the App. You agree not to use the App for any unlawful, abusive, or harmful purposes. Inappropriate content, including but not limited to offensive language, hate speech, harassment, or content violating any intellectual property rights, is strictly prohibited.",
            ),
            SizedBox(height: 10),
            Text(
              "Privacy and Data Security:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            Text(
              "The App collects and processes user data as outlined in the Privacy Policy. By using the App, you consent to the collection, use, and storage of your personal information as described in the Privacy Policy.",
            ),
            SizedBox(height: 10),
            Text(
              "Account Security:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            Text(
              "Users are responsible for maintaining the security and confidentiality of their account login credentials. Any activity that occurs under your account will be your responsibility. In case of unauthorized access, you must notify us immediately.",
            ),
            SizedBox(height: 10),
            Text(
              "Intellectual Property:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            Text(
              "All intellectual property rights, including but not limited to copyrights, trademarks, and patents, in the App and its content, belong to the JUKTO Team or its licensors. Users must not reproduce, modify, distribute, or use any part of the App's content without prior written permission.",
            ),
            SizedBox(height: 10),
            Text(
              "Payment History and GPA Calculation:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            Text(
              "The App provides a feature to store payment history and calculate GPA. While we strive for accuracy, the JUKTO Team reserves the right to review and amend any GPA calculations or payment history discrepancies.",
            ),
            SizedBox(height: 10),
            Text(
              "Alarm and Reminder Features:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            Text(
              "The alarm and reminder features provided in the App are for convenience purposes only. The university does not guarantee the accuracy or reliability of these features and shall not be liable for any missed events or appointments.",
            ),
            SizedBox(height: 10),
            Text(
              "Content Sharing and Messaging:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            Text(
              "Users can share posts, send friend requests, and communicate with each other via messaging. You agree to use these features responsibly and refrain from sharing inappropriate or offensive content.",
            ),
            SizedBox(height: 10),
            Text(
              "App Modifications:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            Text(
              "The JUKTO Team reserves the right to update, modify, or discontinue the App or any part of it without prior notice. These modifications may include adding or removing features or functionalities.",
            ),
            SizedBox(height: 10),
            Text(
              "Termination of Access:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            Text(
              "The JUKTO Team reserves the right to terminate or suspend access to the App at its discretion, without any liability, if a user violates these Terms or engages in any unlawful or harmful activities.",
            ),
            SizedBox(height: 10),
            Text(
              "Disclaimer of Warranties:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            Text(
              "The App is provided \"as is\" without any warranties, express or implied. The university does not guarantee the availability, accuracy, reliability, or suitability of the App for any specific purpose.",
            ),
            SizedBox(height: 10),
            Text(
              "Limitation of Liability:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            Text(
              "In no event shall the JUKTO Team be liable for any direct, indirect, incidental, consequential, or punitive damages arising out of or related to the use of the App.",
            ),
            SizedBox(height: 10),
            Text(
              "Governing Law:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            Text(
              "These Terms shall be governed by and construed in accordance with the laws of the jurisdiction where the university is located, without regard to its conflict of law principles.",
            ),
            SizedBox(height: 10),
            Text(
              "Severability:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            Text(
              "If any provision of these Terms is found to be invalid or unenforceable, such provision shall be severed from the Terms, and the remaining provisions shall remain in full force and effect.",
            ),
            SizedBox(height: 10),
            Text(
              "Entire Agreement:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            Text(
              "These Terms constitute the entire agreement between the user and the JUKTO Team concerning the use of the App, superseding any prior or contemporaneous agreements, communications, or representations.",
            ),
            SizedBox(height: 10),
            Text(
              "By using the JUKTO University-Based Social App, you acknowledge that you have read, understood, and agreed to abide by these Terms and Conditions. If you do not agree with any of the provisions mentioned herein, you must refrain from using the App.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
