enum AccountType {
	YANDEX,
	DROPBOX
}

struct Account {
	1: AccountType type,
	2: string token,
}

struct UserInfo {
	1: string name,
	2: string id,
	3: list<Account> accounts
}

service MultiCloudService
{
	void ping(),
	UserInfo getUserInfo(),
	bool addAccount(1: Account account),
	string createUserByAccount(1: Account account),
	list<string> getImagePaths(),
	list<binary> getAllImages(),
	binary imageByPath(1:string path)
}