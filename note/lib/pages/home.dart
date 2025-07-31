import 'package:flutter/material.dart';
import 'package:note/models/note.dart';
import 'package:note/pages/edit.dart';
import 'package:note/service/db.dart';
import 'package:note/widgets/loading.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Note> notes = [];
  List<Note> filteredNotes = [];
  bool loading = true;
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    refresh();
    _searchController.addListener(_filterNotes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> refresh() async {
    setState(() => loading = true);
    notes = await DB().getNotes();
    filteredNotes = List.from(notes);
    setState(() => loading = false);
  }

  void _filterNotes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredNotes = notes.where((note) {
        return note.title.toLowerCase().contains(query) ||
            note.content.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        _searchController.clear();
        filteredNotes = List.from(notes);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: TextStyle(color: colorScheme.onSurface),
              )
            : Text(
                'NOTES',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
            tooltip: isSearching ? 'Close search' : 'Search',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Edit(note: Note(title: '', content: '')),
            ),
          );
          refresh();
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Loading()
          : filteredNotes.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredNotes.length,
                  itemBuilder: (context, index) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Edit(note: filteredNotes[index]),
                          ),
                        );
                        refresh();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    filteredNotes[index].title,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: colorScheme.error),
                                  onPressed: () => _confirmDelete(filteredNotes[index]),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  tooltip: 'Delete note',
                                ),
                              ],
                            ),
                            if (filteredNotes[index].content.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                filteredNotes[index].content,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.8),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_add,
              size: 72,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              isSearching ? 'No matching notes found' : 'No notes yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            if (!isSearching) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Edit(note: Note(title: '', content: '')),
                    ),
                  );
                  refresh();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Create your first note'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Note note) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Note',
          style: theme.textTheme.titleMedium,
        ),
        content: Text(
          'Are you sure you want to delete this note?',
          style: theme.textTheme.bodyMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => loading = true);
      await DB().delete(note);
      refresh();
    }
  }
}