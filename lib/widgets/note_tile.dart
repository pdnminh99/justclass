import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:justclass/models/note.dart';
import 'package:justclass/models/user.dart';
import 'package:justclass/providers/auth.dart';
import 'package:justclass/providers/note_manager.dart';
import 'package:justclass/utils/mime_type.dart';
import 'package:justclass/widgets/app_snack_bar.dart';
import 'package:justclass/widgets/member_avatar.dart';
import 'package:justclass/widgets/remove_note_alert_dialog.dart';
import 'package:provider/provider.dart';

class NoteTile extends StatelessWidget {
  final Note note;
  final Color color;

  NoteTile({this.note, this.color});

  Future<void> removeNote(BuildContext context) async {
    try {
      final uid = Provider.of<Auth>(context, listen: false).user.uid;
      final noteMgr = Provider.of<NoteManager>(context, listen: false);

      var result = await showDialog<bool>(
        context: context,
        builder: (_) => RemoveNoteAlertDialog(),
      );

      result ??= false;
      if (result) await noteMgr.removeNote(uid, note.noteId);
    } catch (error) {
      AppSnackBar.showError(context, message: error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    const double padding = 15;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400, width: 0.7),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildNoteTopBar(context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: padding),
            child: Text(note.content),
          ),
          if (note.attachments != null) buildAttachmentList(padding),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildNoteTopBar(BuildContext context) {
    final User author = note.author;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: ListTile(
            leading: MemberAvatar(
                photoUrl: author.photoUrl, displayName: author.displayName, color: color),
            title: Text(
              author.displayName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15),
            ),
            subtitle: Text(
              DateFormat('MMM d').format(DateTime.fromMillisecondsSinceEpoch(note.createdAt)),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(25)),
          child: SizedBox(
            width: 50,
            height: 50,
            child: Material(
              color: Colors.transparent,
              child: PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                tooltip: 'Options',
                itemBuilder: (_) => [
                  const PopupMenuItem(child: Text('Edit'), value: 'edit', height: 40),
                  const PopupMenuItem(child: Text('Remove'), value: 'remove', height: 40),
                ],
                onSelected: (val) {
                  if (val == 'edit') {}
                  if (val == 'remove') {
                    removeNote(context);
                  }
                },
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget buildAttachmentList(double padding) {
    return Padding(
      padding: EdgeInsets.only(left: padding, right: padding, top: padding),
      child: Wrap(
        runSpacing: 10,
        spacing: 10,
        children: <Widget>[
          ...note.attachments
              .map((a) => Container(
                    height: 30,
                    constraints: const BoxConstraints(maxWidth: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: Colors.grey.shade400, width: 0.7),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(MimeType.toIcon(a.type), color: color, size: 20),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(a.name, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget buildCommentInteraction() {
    return Container();
  }
}
