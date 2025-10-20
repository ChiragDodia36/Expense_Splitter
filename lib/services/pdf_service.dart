import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/group.dart';
import '../services/balance_service.dart';
import '../services/settlement_service.dart';
import '../utils/currency_formatter.dart';

class PdfService {
  final BalanceService _balanceService = BalanceService();
  final SettlementService _settlementService = SettlementService();

  /// Generate PDF and show share dialog
  Future<void> generateAndSharePdf(BuildContext context, Group group) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating PDF...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final pdfBytes = await generateGroupSummaryPdf(group);
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        // Show PDF preview
        await Printing.layoutPdf(
          name: '${group.name}_expense_report',
          format: PdfPageFormat.a4,
          onLayout: (format) async => pdfBytes,
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        rethrow;
      }
    }
  }

  /// Generate the full PDF document
  Future<Uint8List> generateGroupSummaryPdf(Group group) async {
    final pdf = pw.Document();
    final balances = _balanceService.getMemberBalances(group);
    final settlements = _settlementService.calculateSettlements(group);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(group),
          pw.SizedBox(height: 24),
          _buildMembersSection(group.members),
          pw.SizedBox(height: 24),
          _buildExpensesTable(group),
          pw.SizedBox(height: 24),
          _buildBalancesSection(balances),
          pw.SizedBox(height: 24),
          _buildSettlementsSection(settlements),
          if (group.settlements.isNotEmpty) ...[
            pw.SizedBox(height: 24),
            _buildSettlementHistorySection(group),
          ],
          pw.SizedBox(height: 32),
          _buildFooter(),
        ],
      ),
    );

    return await pdf.save();
  }

  /// Build PDF header
  pw.Widget _buildHeader(Group group) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            group.name,
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generated on ${CurrencyFormatter.formatDate(DateTime.now())}',
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Total Expenses: ${CurrencyFormatter.format(group.totalExpenses)}',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
        ],
      ),
    );
  }

  /// Build members section
  pw.Widget _buildMembersSection(List members) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Members (${members.length})',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Wrap(
          spacing: 10,
          runSpacing: 10,
          children: members.map<pw.Widget>((member) {
            return pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blue),
                borderRadius: pw.BorderRadius.circular(20),
              ),
              child: pw.Text(member.name),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Build expenses table
  pw.Widget _buildExpensesTable(Group group) {
    if (group.expenses.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Center(
          child: pw.Text('No expenses recorded'),
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Expenses (${group.expenses.length})',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildTableCell('Date', isHeader: true),
                _buildTableCell('Description', isHeader: true),
                _buildTableCell('Paid By', isHeader: true),
                _buildTableCell('Amount', isHeader: true, alignment: pw.Alignment.centerRight),
              ],
            ),
            // Expense rows
            ...group.expenses.map((expense) {
              final payer = group.getMemberById(expense.payerId);
              return pw.TableRow(
                children: [
                  _buildTableCell(CurrencyFormatter.formatDateShort(expense.date)),
                  _buildTableCell(expense.description),
                  _buildTableCell(payer?.name ?? 'Unknown'),
                  _buildTableCell(
                    CurrencyFormatter.format(expense.amount),
                    alignment: pw.Alignment.centerRight,
                  ),
                ],
              );
            }),
            // Total row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _buildTableCell(''),
                _buildTableCell(''),
                _buildTableCell('Total', isHeader: true),
                _buildTableCell(
                  CurrencyFormatter.format(group.totalExpenses),
                  isHeader: true,
                  alignment: pw.Alignment.centerRight,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// Build balances section
  pw.Widget _buildBalancesSection(List balances) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Individual Balances',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 12),
        ...balances.map((memberBalance) {
          final balance = memberBalance.balance;
          final isOwed = balance > 0.01;
          final owes = balance < -0.01;
          final color = isOwed ? PdfColors.green : (owes ? PdfColors.red : PdfColors.grey);

          String statusText;
          if (isOwed) {
            statusText = 'gets back ${CurrencyFormatter.format(balance.abs())}';
          } else if (owes) {
            statusText = 'owes ${CurrencyFormatter.format(balance.abs())}';
          } else {
            statusText = 'settled up';
          }

          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 8),
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: color),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  memberBalance.member.name,
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  statusText,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// Build settlements section
  pw.Widget _buildSettlementsSection(List settlements) {
    if (settlements.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(20),
        decoration: pw.BoxDecoration(
          color: PdfColors.green100,
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Center(
          child: pw.Text(
            '✓ All settled up!',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green900,
            ),
          ),
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Suggested Settlements',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue50,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: settlements.map<pw.Widget>((settlement) {
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: 24,
                      height: 24,
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.blue,
                        shape: pw.BoxShape.circle,
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          '→',
                          style: const pw.TextStyle(color: PdfColors.white),
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: pw.Text(
                        '${settlement.from.name} pays ${settlement.to.name} '
                        '${CurrencyFormatter.format(settlement.amount)}',
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Build settlement history section
  pw.Widget _buildSettlementHistorySection(Group group) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Settlement History (${group.settlements.length})',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildTableCell('Date', isHeader: true),
                _buildTableCell('From', isHeader: true),
                _buildTableCell('To', isHeader: true),
                _buildTableCell('Amount', isHeader: true, alignment: pw.Alignment.centerRight),
              ],
            ),
            // Settlement rows
            ...group.settlements.map((settlement) {
              final fromMember = group.getMemberById(settlement.fromMemberId);
              final toMember = group.getMemberById(settlement.toMemberId);
              
              return pw.TableRow(
                children: [
                  _buildTableCell(CurrencyFormatter.formatDateShort(settlement.paidAt)),
                  _buildTableCell(fromMember?.name ?? 'Unknown'),
                  _buildTableCell(toMember?.name ?? 'Unknown'),
                  _buildTableCell(
                    CurrencyFormatter.format(settlement.amount),
                    alignment: pw.Alignment.centerRight,
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  /// Build footer
  pw.Widget _buildFooter() {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Text(
        'Generated by Expense Splitter App',
        style: const pw.TextStyle(
          fontSize: 10,
          color: PdfColors.grey600,
        ),
      ),
    );
  }

  /// Build table cell
  pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    pw.Alignment? alignment,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      alignment: alignment ?? pw.Alignment.centerLeft,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 11,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}

