import 'package:flutter/material.dart';
import 'package:note/models/note.dart';
import 'package:note/service/db.dart';
import 'package:note/widgets/loading.dart';

class Edit extends StatefulWidget {
  final Note note;
  final bool isEditMode;

  const Edit({super.key, required this.note, this.isEditMode = false});

  @override
  State<Edit> createState() => _EditState();
}

class _EditState extends State<Edit> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool _isLoading = false;
  final FocusNode _contentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title ?? '');
    _contentController = TextEditingController(text: widget.note.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditMode ? 'Edit Note' : 'New Note',
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _handleSave,
            tooltip: 'Save',
          ),
          if (widget.isEditMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _handleDelete,
              tooltip: 'Delete',
            ),
        ],
      ),
      body: _isLoading
          ? const Loading()
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      labelText: 'Title',
                      labelStyle: TextStyle(color: colorScheme.onSurface),
                      hintText: 'Enter note title',
                      hintStyle: TextStyle(color: colorScheme.outline),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _contentFocusNode.requestFocus(),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      focusNode: _contentFocusNode,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        labelText: 'Content',
                        labelStyle: TextStyle(color: colorScheme.onSurface),
                        hintText: 'Start typing your note...',
                        hintStyle: TextStyle(color: colorScheme.outline),
                        alignLabelWithHint: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      maxLines: null,
                      expands: true,
                      keyboardType: TextInputType.multiline,
                      textAlignVertical: TextAlignVertical.top,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _handleSave() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Title cannot be empty'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(10),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    widget.note.title = _titleController.text;
    widget.note.content = _contentController.text;
    widget.note.setDate();

    if (widget.isEditMode) {
      await DB().update(widget.note);
    } else {
      await DB().add(widget.note);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _handleDelete() async {
    setState(() => _isLoading = true);
    await DB().delete(widget.note);
    if (!mounted) return;
    Navigator.pop(context, true);
  }
}