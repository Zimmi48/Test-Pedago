/*
Copyright Théo Zimmermann, janvier 2008.
Distribué sous licence GNU GPL v3.

Le module externe impression_systeme est un programme informatique servant 
à imprimer le récapitulatif final du test.
*/


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
