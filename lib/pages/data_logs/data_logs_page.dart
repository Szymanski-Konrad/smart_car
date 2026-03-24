import 'package:flutter/material.dart';
import 'package:smart_car/services/data_logger.dart';

/// Strona do przeglądania zalogowanych sesji danych OBD
class DataLogsPage extends StatefulWidget {
  const DataLogsPage({super.key});

  @override
  State<DataLogsPage> createState() => _DataLogsPageState();
}

class _DataLogsPageState extends State<DataLogsPage> {
  List<LogSessionInfo> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    final sessions = await DataLogger.instance.getLoggedSessions();
    setState(() {
      _sessions = sessions;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zarejestrowane sesje'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadSessions),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
          ? _buildEmptyState()
          : _buildSessionList(),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storage_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Brak zapisanych sesji',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Sesje będą zapisywane automatycznie\npodczas połączenia z pojazdem',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionList() {
    return ListView.builder(
      itemCount: _sessions.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final session = _sessions[index];
        return _SessionCard(
          session: session,
          onTap: () => _showSessionDetails(session),
          onExport: () => _exportSession(session),
          onShare: () => _shareSession(session),
          onDelete: () => _deleteSession(session),
        );
      },
    );
  }

  void _showSessionDetails(LogSessionInfo session) async {
    final fullSession = await DataLogger.instance.loadSession(session.path);
    if (fullSession == null || !mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _SessionDetailsPage(session: fullSession),
      ),
    );
  }

  void _exportSession(LogSessionInfo session) async {
    try {
      final csvPath = await DataLogger.instance.exportToCsv(session.path);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Wyeksportowano do: $csvPath')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Błąd eksportu: $e')));
    }
  }

  void _shareSession(LogSessionInfo session) async {
    try {
      await DataLogger.instance.shareSession(session.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Błąd udostępniania: $e')));
    }
  }

  void _deleteSession(LogSessionInfo session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuń sesję'),
        content: const Text('Czy na pewno chcesz usunąć tę sesję?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Usuń', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DataLogger.instance.deleteSession(session.path);
      _loadSessions();
    }
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.onTap,
    required this.onExport,
    required this.onShare,
    required this.onDelete,
  });

  final LogSessionInfo session;
  final VoidCallback onTap;
  final VoidCallback onExport;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.directions_car, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(session.startTime),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          session.durationFormatted,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'export':
                          onExport();
                          break;
                        case 'share':
                          onShare();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'export',
                        child: Row(
                          children: [
                            Icon(Icons.download),
                            SizedBox(width: 8),
                            Text('Eksportuj CSV'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share),
                            SizedBox(width: 8),
                            Text('Udostępnij'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Usuń', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatChip(
                    icon: Icons.data_usage,
                    label: '${session.readingsCount} odczytów',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.blue),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

/// Strona szczegółów sesji
class _SessionDetailsPage extends StatelessWidget {
  const _SessionDetailsPage({required this.session});

  final LogSession session;

  @override
  Widget build(BuildContext context) {
    // Grupuj odczyty po PID
    final readingsByPid = <String, List<OBDReading>>{};
    for (final reading in session.readings) {
      readingsByPid.putIfAbsent(reading.pid, () => []).add(reading);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Szczegóły sesji')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Metadata
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informacje o sesji',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow('Start', _formatDateTime(session.startTime)),
                  if (session.endTime != null)
                    _InfoRow('Koniec', _formatDateTime(session.endTime!)),
                  _InfoRow('Czas trwania', session.durationFormatted),
                  _InfoRow('Liczba odczytów', '${session.readings.length}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Stats per PID
          const Text(
            'Statystyki parametrów',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...readingsByPid.entries.map((entry) {
            final readings = entry.value;
            final values = readings.map((r) => r.value).toList();
            final min = values.reduce((a, b) => a < b ? a : b);
            final max = values.reduce((a, b) => a > b ? a : b);
            final avg = values.reduce((a, b) => a + b) / values.length;

            return Card(
              child: ListTile(
                title: Text(readings.first.name),
                subtitle: Text(
                  'Min: ${min.toStringAsFixed(1)} | Avg: ${avg.toStringAsFixed(1)} | Max: ${max.toStringAsFixed(1)} ${readings.first.unit}',
                ),
                trailing: Text(
                  '${readings.length}x',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}.${dt.month}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value),
        ],
      ),
    );
  }
}
