import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: t.surface,
              shape: BoxShape.circle,
              border: Border.all(color: t.border),
            ),
            child: Icon(Icons.chevron_left_rounded, color: t.text),
          ),
        ),
        title: Text(
          'Conditions d\'utilisation',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: t.text,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            24, 16, 24, MediaQuery.of(context).padding.bottom + 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(t, 'Poopy — Conditions Générales d\'Utilisation'),
            _meta(t, 'Version 1.0 · En vigueur au 1er juin 2026'),
            const SizedBox(height: 24),

            _section(t, '1. Présentation de l\'application',
                'Poopy est une application mobile d\'accompagnement destinée aux personnes atteintes de Maladies Inflammatoires Chroniques de l\'Intestin (MICI), notamment la maladie de Crohn, la rectocolite hémorragique (RCH) et les MICI indéterminées.\n\n'
                'Poopy permet de suivre au quotidien les épisodes digestifs, les traitements, le poids, les rendez-vous médicaux et les analyses biologiques.'),

            _section(t, '2. Avertissement médical important',
                'Poopy est un outil de suivi personnel. Elle ne constitue en aucun cas un dispositif médical, un outil de diagnostic, ni un substitut à un avis médical professionnel.\n\n'
                'Les informations et données enregistrées dans l\'application sont fournies à titre informatif uniquement. En cas de symptômes graves, consultez immédiatement un médecin ou les services d\'urgence.\n\n'
                'Poopy ne saurait être tenue responsable de décisions médicales prises sur la base des données affichées dans l\'application.'),

            _section(t, '3. Création de compte et accès',
                'L\'utilisation de Poopy nécessite la création d\'un compte avec un nom d\'utilisateur et une adresse e-mail valide. Vous êtes responsable de la confidentialité de vos identifiants.\n\n'
                'Poopy se réserve le droit de suspendre ou supprimer tout compte en cas d\'utilisation frauduleuse ou contraire aux présentes conditions.'),

            _section(t, '4. Données personnelles et confidentialité',
                'Vos données de santé (symptômes, traitements, analyses, poids) sont strictement personnelles et ne sont jamais partagées avec des tiers à des fins commerciales.\n\n'
                'Les données sont stockées de manière sécurisée. Conformément au Règlement Général sur la Protection des Données (RGPD), vous disposez des droits suivants :\n\n'
                '• Droit d\'accès à vos données\n'
                '• Droit de rectification\n'
                '• Droit à l\'effacement (« droit à l\'oubli »)\n'
                '• Droit à la portabilité\n\n'
                'Pour exercer ces droits, contactez-nous via les coordonnées indiquées en section 8.'),

            _section(t, '5. Données de santé sensibles',
                'Les données relatives à la santé constituent des données dites « sensibles » au sens du RGPD. En utilisant Poopy et en saisissant vos informations médicales, vous consentez explicitement à leur traitement par l\'application dans le seul but de vous fournir le service de suivi personnalisé.\n\n'
                'Ces données ne sont ni vendues, ni louées, ni transmises à des organismes tiers.'),

            _section(t, '6. Propriété intellectuelle',
                'L\'ensemble des éléments constitutifs de Poopy (logo, design, code, textes, illustrations) sont la propriété exclusive de leurs auteurs et sont protégés par le droit de la propriété intellectuelle.\n\n'
                'Toute reproduction, modification ou utilisation non autorisée est strictement interdite.'),

            _section(t, '7. Limitation de responsabilité',
                'Poopy est fournie « en l\'état », sans garantie d\'aucune sorte. Nous ne garantissons pas l\'absence d\'interruptions de service, d\'erreurs ou de pertes de données.\n\n'
                'En aucun cas Poopy ne pourra être tenue responsable de dommages directs ou indirects résultant de l\'utilisation ou de l\'impossibilité d\'utiliser l\'application.'),

            _section(t, '8. Contact',
                'Pour toute question relative aux présentes conditions ou à la gestion de vos données personnelles, vous pouvez nous contacter à l\'adresse suivante :\n\n'
                '📧 support.poopy@gmail.com'),

            _section(t, '9. Modifications des conditions',
                'Poopy se réserve le droit de modifier les présentes conditions à tout moment. Les utilisateurs seront informés de toute modification substantielle via une notification dans l\'application.\n\n'
                'La poursuite de l\'utilisation de l\'application après modification vaut acceptation des nouvelles conditions.'),

            _section(t, '10. Droit applicable',
                'Les présentes conditions sont régies par le droit français. Tout litige relatif à leur interprétation ou leur exécution relève de la compétence exclusive des tribunaux français.'),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: t.border),
              ),
              child: Text(
                'En créant un compte sur Poopy, vous reconnaissez avoir lu, compris et accepté l\'intégralité des présentes conditions d\'utilisation.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: t.textDim,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(AppThemeExtension t, String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Quicksand',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: t.text,
        height: 1.3,
      ),
    );
  }

  Widget _meta(AppThemeExtension t, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          color: t.textMuted,
        ),
      ),
    );
  }

  Widget _section(AppThemeExtension t, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: t.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: t.textDim,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
