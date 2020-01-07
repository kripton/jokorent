#ifndef MODEL_H
#define MODEL_H

#include <QJsonObject>
#include <QObject>
#include <QString>

class Model
{
    Q_GADGET

public:
    Model();
    Model(int id, const QString &maker, const QString &name, const QString &type);

    int id() const;
    void setId(int id);

    QString maker() const;
    void setMaker(const QString &maker);

    QString name() const;
    void setName(const QString &name);

    QString type() const;
    void setType(const QString &type);

    void read(const QJsonObject &json);
    void write(QJsonObject &json) const;

    void print(int indentation = 0) const;

private:
    int mId;
    QString mMaker;
    QString mName;
    QString mType;
};

#endif // MODEL_H
