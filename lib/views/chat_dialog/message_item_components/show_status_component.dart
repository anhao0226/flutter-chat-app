import 'dart:io';

import 'package:desktop_app/utils/dio_instance.dart';
import 'package:flutter/material.dart';

enum Status { loading, unread, hidden, error }

class ShowStatusComponent extends StatefulWidget {
  const ShowStatusComponent({
    super.key,
    required this.url,
    required this.filepath,
    required this.status,
    this.onDownload,
  });

  final String url;
  final Status status;
  final String filepath;
  final VoidCallback? onDownload;

  @override
  State<StatefulWidget> createState() => _ShowStatusComponentState();
}

class _ShowStatusComponentState extends State<ShowStatusComponent> {
  Status _status = Status.loading;

  @override
  void initState() {
    _status = widget.status;

    // if (File(widget.filepath).existsSync()) {
    //   _status = widget.status;
    // } else {
    //   _status = Status.loading;
    //   _handleDownloadFile(() {
    //     setState(() => _status = widget.status);
    //   });
    // }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ShowStatusComponent oldWidget) {
    if (widget.status != oldWidget.status) {
      setState(() => _status = widget.status);
    }
    super.didUpdateWidget(oldWidget);
  }

  // 处理文件上传
  void _handleDownloadFile(VoidCallback success) {
    // handleDownloadFile(
    //   widget.url,
    //   widget.filepath,
    //   onSuccess: (filepath, data) {
    //     success();
    //     if (widget.onDownload != null) {
    //       widget.onDownload!();
    //     }
    //   },
    //   onSendProgress: (count, total) {
    //     // setState(() => _progressValue = count / total);
    //   },
    // );
  }

  // 处理文件下载
  void _handleUploadFile(VoidCallback success) {
    // handleDownloadFile(
    //   widget.url,
    //   widget.filepath,
    //   onSuccess: (filepath, data) {
    //     success();
    //     if (widget.onDownload != null) {
    //       widget.onDownload!();
    //     }
    //   },
    //   onSendProgress: (count, total) {
    //     // setState(() => _progressValue = count / total);
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      constraints: const BoxConstraints(
        minHeight: 36,
      ),
      child: _buildStateUI(),
    );
  }

  Widget _buildStateUI() {
    switch (_status) {
      case Status.loading:
        return Container(
          height: 38.0,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 16.0,
            height: 16.0,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.black12,
            ),
          ),
        );
      case Status.unread:
        return Container(
          width: 6.0,
          height: 6.0,
          decoration: const BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.all(
              Radius.circular(3),
            ),
          ),
          alignment: Alignment.center,
        );
      default:
        return Container();
    }
  }
}
