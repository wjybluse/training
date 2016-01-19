//: Playground - noun: a place where people can play
import Foundation
extension Array{
    internal mutating func remove_obj<T where T:Equatable>(objec: T){
        let index = find(objec)
        if let idx = index{
            self.removeAtIndex(idx)
        }
    }
    
    private mutating func find<T where T:Equatable>(objec: T)->Int?{
        var idx: Int?
        for (index,value) in self.enumerate(){
            if let _ = value as? T{
                idx = index
            }
        }
        return idx
    }
}
class Role: Equatable{
    var name:String?
    var id:String
    var parents:[Role?]?
    var permission:[String?]?
    init(id:String,name: String?,parents: [Role?]?,permission: [String?]?){
        self.id = id
        self.name = name
        self.parents = parents
        self.permission = permission
    }
    
    internal func add_pemission(permission: [String?]?)->Role{
        permission?.map({p in
            self.permission?.append(p)
        })
        return self
        
    }
    
    internal func remove_permission(permission: [String?]?)->Role{
        permission?.forEach({
            item in
            //find item without nil
            if let _item = item{
                self.permission?.remove_obj(_item)
            }
            
        })
        return self
    }
    
    internal func contains_permission(permission: String)->Bool{
        let result = self.permission?.contains({p in
            if let _p = p{
               return  _p == permission
            }
            return false
        })
        guard let r = result where r else{
            return find_recursive(self.parents, permission: permission)
        }
        return r
    }
    
    private func find_recursive(roles: [Role?]?,permission: String)->Bool{
        var flag: Bool = false
        roles?.forEach({
            role in
            if let allow = role?.contains_permission(permission){
                if allow{
                    flag = true
                }
            }
        })
        return flag
    }
    
    internal func add_parents(parents: [Role?]?)->Role{
        parents?.forEach(){
            parent in
            self.parents?.append(parent)
        }
        return self
    }
}

func ==(lhs: Role, rhs: Role) -> Bool {
    //name is unique identify
    return lhs.name==rhs.name

}

protocol DataAccess{
    func load_roles() -> [Role]
    func save_role(role: Role)
    func remove_role(role: Role)
    func dump_roles() -> [Role]
}


class FileDataAccess:DataAccess{
    var roles: [Role] = []
    func load_roles() -> [Role]{
        return roles
    }
    func save_role(role: Role){
        let value = self.roles.contains({
            r in r.name == role.name
        })
        if value{
            //update store file
            print("update store file item item \(role)")
        }else{
            print("save the file")
            roles.append(role)
        }
    }
    
    func remove_role(role: Role){
        self.roles.remove_obj(role)
    }
    func dump_roles() -> [Role]{
        print(self.roles)
        return roles
    }
}


class RoleController{

    var mapping: [String:Role] = [:]
    
    var data_access: DataAccess
    
    init(mapping: [String:Role]){
        self.mapping = mapping
        self.data_access = FileDataAccess()
    }
    
    init(){
        self.data_access = FileDataAccess()
        self.data_access.load_roles().forEach({
            role in
            if let name = role.name{
                mapping[name] = role
            }
            
        })
    }
    
    internal func add_role(name: String,permission: [String?]?, parents: [Role?]?,desc: String?)->Role{
        let role = Role(id: "", name: name, parents: parents, permission: permission)
        mapping[name]=role
        return role
    }
    
    internal func remove_role(name: String){
        mapping.removeValueForKey(name)
    }
    
    internal func can_access(name: String,opt: String)->Bool{
        guard let ret = mapping[name]?.contains_permission(opt) else{
            return false
        }
        return ret
    }
}



let rc = RoleController()
let parent1 = Role(id: "",name: "query",parents: nil,permission: ["query","add"])
let parent2 = Role(id: "",name: "modify",parents: nil,permission: ["modify","bom"])
let parent3 = Role(id: "",name: "heh",parents: nil,permission: ["hehhe"])
let parent4 = Role(id: "",name:"res1",parents: [parent3],permission: ["hah"] )
rc.add_role("wan1", permission: ["delete","update"], parents:[parent1,parent2,parent4], desc: "hahha")
assert(rc.can_access("wan1" , opt: "delete"))
assert(!rc.can_access("wan1", opt: "sha"))
assert(rc.can_access("wan1", opt: "query"))
rc.add_role("res", permission:nil, parents: [parent4], desc: "ok")
assert(!rc.can_access("res", opt: "delete"))
assert(rc.can_access("res", opt: "hehhe"))


