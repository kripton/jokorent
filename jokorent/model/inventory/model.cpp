#include "model.h"

#include <QMetaEnum>
#include <QTextStream>

Model::Model() :
    mId(0),
    mMaker(),
    mName(),
    mType()
{
}

Model::Model(int id, const QString &maker, const QString &name, const QString &type) :
    mId(id),
    mMaker(maker),
    mName(name),
    mType(type)
{
}

int Model::id() const
{
    return mId;
}

void Model::setId(const int id)
{
    mId = id;
}

QString Model::maker() const
{
    return mMaker;
}

void Model::setName(const QString &name)
{
    mName = name;
}

QString Model::type() const
{
    return mType;
}

void Model::setType(const QString &type)
{
    mType = type;
}

void Model::read(const QJsonObject &json)
{
    if (json.contains("id"))
        mId = json["id"].toInt();

    if (json.contains("maker") && json["maker"].isString())
        mMaker = json["maker"].toString();

    if (json.contains("name") && json["name"].isString())
        mName = json["name"].toString();

    if (json.contains("type") && json["type"].isString())
        mType = json["type"].toString();
}

void Model::write(QJsonObject &json) const
{
    json["id"] = mId;
    json["maker"] = mMaker;
    json["name"] = mName;
    json["type"] = mType;
}

void Model::print(int indentation) const
{
    const QString indent(indentation * 2, ' ');
    QTextStream(stdout) << indent << "Id:\t" << mId << "\n";
    QTextStream(stdout) << indent << "Maker:\t" << mMaker << "\n";
    QTextStream(stdout) << indent << "Name:\t" << mName << "\n";
    QTextStream(stdout) << indent << "Type:\t" << mType << "\n";
}
