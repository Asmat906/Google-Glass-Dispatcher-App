import 'dart:io';

import 'package:enough_mail/enough_mail.dart';
import 'package:google_glass_dispatcher/database/db_technicican.dart';
import 'package:google_glass_dispatcher/consts/mail_settings.dart';
import 'package:http_parser/http_parser.dart';

class Mail {

  String userName = MAIL_USERNAME;
  String password = MAIL_PASSWORD;

  bool isImapServerSecure = true;

  String imapServerHost = IMAP_SERVER_HOST;
  int imapServerPort = IMAP_SERVER_PORT;

  String smtpServerHost = SMTP_SERVER_HOST;
  int smtpServerSSLPort = SMTP_SERVER_SSL_PORT;
  int smtpServerTLSPort = SMTP_SERVER_TLS_PORT;
  bool isSmtpServerSecure = true;

  Future<void> sendEmail(String content, DateTime dt, TechnicianDO technician, String type) async {

    final client = SmtpClient('enough.de', isLogEnabled: true);
    try {
      await client.connectToServer(smtpServerHost, smtpServerSSLPort,
          isSecure: isSmtpServerSecure);
      await client.ehlo();
      await client.authenticate(userName, password);
      final builder = MessageBuilder.prepareMultipartAlternativeMessage();
      builder.from = [MailAddress('HWG DISPATCHER', MAIL_USERNAME)];
      if(type=="intern" && technician.shortcut!="none"){
        builder.to = [MailAddress(technician.shortcut, technician.techEmail)];
        //builder.addTextPlain(content);
        builder.subject = "Neuer Auftrag [${dt.year}.${dt.month}.${dt.day}]" ;
        builder.addTextPlain(content);
        // builder.addTextHtml('<p>hello <b>world</b></p>');
        final mimeMessage = builder.buildMimeMessage();
        final sendResponse = await client.sendMessage(mimeMessage);
      }
      else if(type=="delete"){
        builder.to = [MailAddress(technician.shortcut, technician.techEmail)];
        //builder.addTextPlain(content);
        builder.subject = "Neuer Auftrag [${dt.year}.${dt.month}.${dt.day}]-del" ;
        builder.addTextPlain(content);
        // builder.addTextHtml('<p>hello <b>world</b></p>');
        final mimeMessage = builder.buildMimeMessage();
        final sendResponse = await client.sendMessage(mimeMessage);
      }
      else {
        builder.to = [MailAddress(technician.name, technician.email)];
        //builder.addTextHtml(content);
        builder.subject = "Neuer Auftrag [${dt.year}.${dt.month}.${dt.day}]" ;
        builder.addTextHtml(content);
        // builder.addTextHtml('<p>hello <b>world</b></p>');
        final mimeMessage = builder.buildMimeMessage();
        final sendResponse = await client.sendMessage(mimeMessage);
        print('message sent: ${sendResponse.isOkStatus}');
      }
      /*builder.subject = "Neuer Auftrag [${dt.year}.${dt.month}.${dt.day}]" ;
      builder.addTextPlain(content);
      // builder.addTextHtml('<p>hello <b>world</b></p>');
      final mimeMessage = builder.buildMimeMessage();
      final sendResponse = await client.sendMessage(mimeMessage);
      print('message sent: ${sendResponse.isOkStatus}');*/
    } on SmtpException catch (e) {
      print('SMTP failed with $e');
    }
  }

  Future<void> imapExample() async {
    final client = ImapClient(isLogEnabled: false);
    try {
      await client.connectToServer(imapServerHost, imapServerPort, isSecure: isImapServerSecure);
      await client.login(userName, password);
      final mailboxes = await client.listMailboxes();
      print('mailboxes: $mailboxes');
      await client.selectInbox();
      // fetch 10 most recent messages:
      // final fetchResult = await client.fetchRecentMessages(messageCount: 10, criteria: 'BODY.PEEK[]');
      // for (final message in fetchResult.messages) {
      //   printMessage(message);
      // }
      await client.logout();
    } on ImapException catch (e) {
      print('IMAP failed with $e');
    }
  }

  void printMessage(MimeMessage message) {
    print('from: ${message.from} with subject "${message.decodeSubject()}"');
    if (!message.isTextPlainMessage()) {
      print(' content-type: ${message.mediaType}');
    } else {
      final plainText = message.decodeTextPlainPart();
      if (plainText != null) {
        final lines = plainText.split('\r\n');
        for (final line in lines) {
          if (line.startsWith('>')) {
            // break when quoted text starts
            break;
          }
          print(line);
        }
      }
    }
  }
}
