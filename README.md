# CircleCIによるRailsアプリのビルド・テスト・デプロイメントの自動化
## 概要
- CloudFormationによるインフラ構築
- Ansibleによるサーバー環境構築とアプリのデプロイ
- Serverspecによるインフラテスト
- 上記をGItHubへのpushをトリガーにCircleCIで一気通貫におこなう

## 使用ツール
- CircleCI
- CloudFormation
- Ansible
- Serverspec

## 事前準備
- CircleCIとAWSをOICD連携する。
- EC2用のKeyPairを発行し、CircleCIのSSHパーミッションに設定する。

## 実装手順
詳しくは[こちら](https://github.com/mkmmr/aws-practice/blob/main/lecture13.md)をご参照ください。

1. Ansble 実装手順
    - ローカルPCにAnsbleをインストール
    - ローカルPCにSSH接続用キーを準備
    - AnsibleからEC2インスタンスに接続
    - playbook.ymlにサーバー環境構築とアプリのデプロイについて記述
    - Ansibleで遭遇したエラー
2. CircleCI 実装手順
	- CircleCIとAWSをOIDC連携
	- CircleCIにCloudFormationを実装
	- CircleCIにAnsibleを実装
3. Serverspec 実装手順
	- CircleCIにServerspecを実装
	- ServerspecからEC2にSSH接続
	- Serverspecテストの実装
	- Serverspecで遭遇したエラー

## 構成図
![CircleCI自動化の構成図](https://github.com/mkmmr/aws-practice/blob/main/images/aws_lecture13_07diagram.png)

## こだわりポイント
- CircleCIからAWSへの接続には、OICD連携してSTSを発行し、AssumeRoleで接続します。
- 画像はS3に保存されます。
- S3用のIAMロール、ALBは自動作成します。
