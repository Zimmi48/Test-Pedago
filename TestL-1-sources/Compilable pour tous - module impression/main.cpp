/*Le module externe impression_systeme est un programme informatique servant 
à imprimer le récapitulatif final du test. 

Ce programme est un logiciel libre; vous pouvez le redistribuer et/ou
le modifier sous les termes de la Licence Publique Générale GNU
(GNU General Public License) comme publiée par la Free Software Foundation;
soit sous la version 3 de la Licence, soit (à votre guise) sous toute
version ultérieure.

Ce programme est distribué dans l'espoir qu'il sera utile mais SANS AUCUNE
GARANTIE; sans même la garantie implicite qu'il soit ADAPTE A LA 
COMMERCIALISATION ou qu'il soit ADAPTE POUR UN USAGE PARTICULIER. Référez-vous
à la GNU General Public License pour plus de détails.

Vous devriez avoir reçu une copie de la GNU General Public License jointe
avec ce programme; si non, écrivez à la Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

Ce second avertissement (relatif au module) est une traduction non
officielle, pour l'original, seul véritablement valable, voir la suite.



The external module impression_systeme is a computer program whose
purpose is to print the final summary of the test. 

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.*/


#include <QApplication>
#include <QTranslator>
#include <QLocale>
#include <QLibraryInfo>
#include <QPrinter>
#include <QPrintDialog>
#include <QPainter>
#include <QFile>
#include <QTextStream>
#include <QString>

int main(int argc, char *argv[])
{
	QApplication app(argc, argv);

	QString locale = QLocale::system().name();
	QTranslator translator;
	translator.load(QString("qt_") + locale, QLibraryInfo::location(QLibraryInfo::TranslationsPath));
	app.installTranslator(&translator);
	
	QFile fichier("imprime.txt");
	if (fichier.open(QIODevice::ReadOnly | QIODevice::Text))
	{
		QTextStream entree(&fichier);
		
		QPrinter printer;

		QPrintDialog dialog(&printer);
		//dialog.setObjectName(QString("Imprimer le récapitulatif"));
		if (dialog.exec() == QDialog::Accepted)
		{
			QPainter painter;
			painter.begin(&printer);
			int i = 40;
			painter.setFont(QFont("Machine", 14));
			while (!entree.atEnd())
			{
				painter.drawText(60, i+=20, entree.readLine()); //, 660, 880, Qt::AlignBottom, entree.readLine());
			}
			painter.end();
		}
	}
    
	//fenetre.show();

    return 0; //app.exec();
}
